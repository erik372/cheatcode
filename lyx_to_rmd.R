# ==============================================================
# lyx_to_rmd.R
# Converts chapters 0-5 (preface + ch1-5) of the LyX book
# to bookdown Rmd files.
# Run from the bookdown-project directory.
# ==============================================================

library(stringr)

lyx_path <- "Hegelund - The Cheat Code - 260527.lyx"
lines <- readLines(lyx_path, encoding = "UTF-8", warn = FALSE)
n <- length(lines)
message("Read ", n, " lines from LyX file.")

# Inline citation lookup: key → formatted Markdown with URL
CITATION_MAP <- list(
  "jonesGDPWelfareCountries2016"                  = "[Jones & Klenow (2016)](https://www.aeaweb.org/articles?id=10.1257/aer.20110236)",
  "millerEtherDriftExperimentDetermination1933"   = "[Miller (1933)](https://link.aps.org/doi/10.1103/RevModPhys.5.203)",
  "letreutHistoricalOverviewClimate2005"           = "[IPCC (2007)](https://www.ipcc.ch/report/ar4/wg1/)",
  "huntington-kleinLinearRescalingAccurately2021" = "[Huntington-Klein (2021)](https://theeffectbook.net)",
  "cobbTheoryProduction1928"                       = "[Cobb & Douglas (1928)](https://www.jstor.org/stable/1811556)"
)

# Chapters that are locked (reviewed and approved — will NOT be overwritten).
# Add a filename here when a chapter is done and you want to edit it manually.
LOCKED_CHAPTERS <- c(
  "index.Rmd",
  "01-why-math.Rmd",
  "02-basics.Rmd",
  "03-examples-applications.Rmd",
  "04-functions-graphs.Rmd",
  "05-logarithms.Rmd",
  "06-polynomial-equations.Rmd",
  "07-systems-linear-equations.Rmd",
  "08-theories-life-death-dating.Rmd",
  "09-nonlinear-equations-systems.Rmd",
  "10-derivative.Rmd",
  "11-optimization-functions.Rmd",
  "12-theories-cake-monopoly.Rmd",
  "13-integration.Rmd",
  "14-linear-algebra.Rmd"
)

# Per-figure out.width overrides (chunk_id -> width string)
FIG_WIDTH_OVERRIDES <- list(
  "time-series-index"          = "46%",   # Fig 3.1: reduced 35% from 71%
  "illustration-av-funktionen" = "92%"    # Fig 4.1: enlarged 30% from 71%
)

# ==============================================================
# render_inset: convert inset content to inline Markdown/LaTeX
# ==============================================================
render_inset <- function(spec, content_items) {
  spec <- trimws(spec)
  # Split spec into type and args
  m <- regexpr("^(\\S+)\\s*(.*)$", spec, perl = TRUE)
  inset_type <- regmatches(spec, m)
  if (length(inset_type) == 0 || nchar(inset_type) == 0) return("")
  parts  <- str_match(spec, "^(\\S+)\\s*(.*)$")
  inset_type <- if (!is.na(parts[1,2])) parts[1,2] else spec
  inset_args <- if (!is.na(parts[1,3])) trimws(parts[1,3]) else ""

  # Collapse content to text (already rendered sub-items)
  raw_lines <- unlist(content_items)
  content_text <- paste(Filter(function(x) nchar(trimws(x)) > 0, raw_lines), collapse = " ")
  content_text <- trimws(content_text)

  switch(inset_type,
    # ---- Skip these entirely ----
    "Note"          = return(""),
    "ERT"           = return(""),
    "Index"         = return(""),
    "Newpage"       = return(""),
    "Marginal"      = return(""),
    "listings"      = {
      # Code listing - wrap in verbatim
      code <- paste(raw_lines, collapse = "\n")
      code <- trimws(code)
      return(paste0("\n\n```\n", code, "\n```\n\n"))
    },

    # ---- Whitespace ----
    "space"   = return(" "),   # non-breaking space
    "Newline" = return("\n"),

    # ---- CommandInset ----
    "CommandInset" = {
      cmd_type <- str_split(inset_args, "\\s+")[[1]][1]
      switch(cmd_type,
        "label" = {
          name_match <- grep('^name "', raw_lines, value = TRUE)
          if (length(name_match) > 0) {
            lbl_name <- gsub('^name "(.*)"$', "\\1", name_match[1])
            return(paste0("@@@LABEL@@@", lbl_name, "@@@/LABEL@@@"))
          }
          return("")
        },
        "ref" = {
          ref_match <- grep('^reference "', raw_lines, value = TRUE)
          if (length(ref_match) > 0) {
            ref_name <- gsub('^reference "(.*)"$', "\\1", ref_match[1])
            # Map LyX prefix to bookdown ref type
            if (grepl("^fig:", ref_name)) {
              lbl <- make_label(sub("^fig:", "", ref_name))
              return(paste0("\\@ref(fig:", lbl, ")"))
            } else if (grepl("^eq:", ref_name)) {
              lbl <- make_label(sub("^eq:", "", ref_name))
              return(paste0("\\@ref(eq:", lbl, ")"))
            } else if (grepl("^tab:", ref_name)) {
              lbl <- make_label(sub("^tab:", "", ref_name))
              return(paste0("\\@ref(tab:", lbl, ")"))
            } else {
              lbl <- make_label(ref_name)
              return(paste0("\\@ref(", lbl, ")"))
            }
          }
          return("")
        },
        "citation" = {
          key_match <- grep('^key "', raw_lines, value = TRUE)
          if (length(key_match) > 0) {
            keys <- gsub('^key "(.*)"$', "\\1", key_match[1])
            key_list <- trimws(str_split(keys, ",")[[1]])
            parts_cited <- sapply(key_list, function(k) {
              if (!is.null(CITATION_MAP[[k]])) CITATION_MAP[[k]] else paste0("[@", k, "]")
            })
            return(paste(parts_cited, collapse = "; "))
          }
          return("")
        },
        return("")
      )
    },

    # ---- Formulas ----
    "Formula" = {
      # Inline: formula on the spec line itself
      if (nchar(inset_args) > 0) {
        # Multi-line inline formula: spec line starts with $ but has no closing $
        # e.g. \begin_inset Formula $\begin{cases}...\end{cases}$
        if (grepl("^\\$", inset_args) && !grepl("\\$$", trimws(inset_args)) && length(raw_lines) > 0) {
          full_str <- trimws(paste(c(inset_args, raw_lines), collapse = "\n"))
          if (substr(full_str, 1, 1) == "$" && substr(full_str, nchar(full_str), nchar(full_str)) == "$") {
            inner <- trimws(substr(full_str, 2, nchar(full_str) - 1))
            return(paste0("\n\n$$\n", inner, "\n$$\n\n"))
          }
        }
        # $\$N$ = currency dollar sign in math mode → plain $N
        cleaned <- gsub("^\\$\\\\\\$([^$]*)\\$$", "$\\1", inset_args, perl = TRUE)
        # Trim whitespace inside $...$ (LyX sometimes includes trailing spaces)
        cleaned <- gsub("^\\$\\s*(.*?)\\s*\\$$", "$\\1$", cleaned, perl = TRUE)
        if (cleaned == "$$" || cleaned == "$") return("")
        return(cleaned)
      }
      # Display: formula in content lines
      formula_content <- paste(raw_lines, collapse = "\n")
      formula_content <- trimws(formula_content)
      # Move \ensuremath{X} out of \text{} — handles nested braces (e.g. 10^{1})
      # Repeat until no more matches (handles multiple \ensuremath in one \text{})
      arg1 <- "((?:[^{}]|\\{[^{}]*\\})*)"  # one-level-nested brace content
      repeat {
        new_fc <- gsub(
          paste0("\\\\text\\{([^{}]*)\\\\ensuremath\\{", arg1, "\\}([^{}]*)\\}"),
          "\\\\text{\\1}\\2\\\\text{\\3}", formula_content, perl = TRUE)
        if (identical(new_fc, formula_content)) break
        formula_content <- new_fc
      }
      formula_content <- gsub("\\\\text\\{\\}", "", formula_content, perl = TRUE)
      # Strip any remaining \ensuremath{} wrappers (already in math context)
      formula_content <- gsub(paste0("\\\\ensuremath\\{", arg1, "\\}"),
                               "\\1", formula_content, perl = TRUE)
      if (nchar(formula_content) == 0) return("")
      # Detect inline wrapped in \( \)
      if (grepl("^\\\\\\(", formula_content) && grepl("\\\\\\)$", formula_content)) {
        inner <- sub("^\\\\\\(\\s*", "", formula_content)
        inner <- sub("\\s*\\\\\\)$", "", inner)
        return(paste0("$", inner, "$"))
      }
      # Extract \label{eq:...} from display formula → bookdown tag (\#eq:id)
      eq_label_tag <- ""
      lbl_raw <- regmatches(formula_content,
                            regexpr("\\\\label\\{([^}]*)\\}", formula_content, perl = TRUE))
      if (length(lbl_raw) > 0 && nchar(lbl_raw) > 0) {
        lbl_inner <- sub("^\\\\label\\{", "", sub("\\}$", "", lbl_raw))
        lbl_inner <- trimws(sub("^eq:\\s*", "", lbl_inner))
        eq_label_tag <- paste0(" (\\#eq:", make_label(lbl_inner), ")")
        formula_content <- gsub("\\\\label\\{[^}]*\\}", "", formula_content, fixed = FALSE)
      }
      # Inject tag before last \end{...} (align/equation) or before closing $$
      if (nchar(eq_label_tag) > 0) {
        if (grepl("\\\\end\\{", formula_content, perl = TRUE)) {
          m <- gregexpr("\\\\end\\{[^}]+\\}", formula_content, perl = TRUE)[[1]]
          if (!is.na(m[1])) {
            lp <- tail(m, 1)
            formula_content <- paste0(substr(formula_content, 1, lp - 1), eq_label_tag, "\n",
                                      substr(formula_content, lp, nchar(formula_content)))
          }
        } else {
          formula_content <- paste0(formula_content, eq_label_tag)
        }
      }
      # \[ ... \] or LaTeX env
      if (grepl("^\\\\\\[", formula_content)) {
        inner <- sub("^\\\\\\[\\s*", "", formula_content)
        inner <- sub("\\s*\\\\\\]$", "", inner)
        return(paste0("\n\n$$\n", inner, "\n$$\n\n"))
      }
      return(paste0("\n\n$$\n", formula_content, "\n$$\n\n"))
    },

    # ---- Floats (figures, tables) ----
    "Float" = {
      float_type <- tolower(str_split(inset_args, "\\s+")[[1]][1])
      if (float_type == "figure") {
        return(render_float_figure(raw_lines, content_items))
      }
      if (float_type == "table") {
        return(render_float_table(raw_lines, content_items))
      }
      return(paste0("\n\n", content_text, "\n\n"))
    },

    # ---- Graphics ----
    "Graphics" = {
      fn_line <- grep("^\\s*filename", raw_lines, value = TRUE)
      if (length(fn_line) > 0) {
        filename <- trimws(sub("^\\s*filename\\s*", "", fn_line[1]))
        return(paste0("FIGFILE:", filename, ":FIGFILE"))
      }
      return("")
    },

    # ---- Captions ----
    "Caption" = return(paste0("@@@CAP@@@", content_text, "@@@/CAP@@@")),

    # ---- Text inside tabular cells ----
    "Text" = return(content_text),

    # ---- Tabular ----
    "Tabular" = {
      return(parse_tabular(raw_lines, content_items))
    },

    # ---- Box environments (Shadowbox/Boxed = callout, Frameless = transparent) ----
    "Box" = {
      box_attr_pat <- paste0("^(position|hor_pos|has_inner_box|inner_pos|use_parbox|",
                             "use_makebox|width|special|height|height_special|thickness|",
                             "separation|shadowsize|framecolor|backgroundcolor|status)\\s")
      filtered <- Filter(function(x) !grepl(box_attr_pat, trimws(x)), raw_lines)
      box_text  <- trimws(paste(Filter(function(x) nchar(trimws(x)) > 0, filtered), collapse = "\n"))
      if (grepl("Frameless", inset_args, fixed = TRUE)) {
        return(box_text)  # layout box only — return content as-is
      }
      return(paste0('\n\n::: {.callout-box}\n', box_text, '\n:::\n\n'))
    },

    # ---- Hyperlinks ----
    "CommandInset" = return(""),

    # Default: return collapsed content
    return(content_text)
  )
}

# Extract a figure from float content
render_float_figure <- function(raw_lines, content_items) {
  # Filter out Float-level attribute lines that leaked via add_to_top
  float_attr_pat <- "^(placement|alignment|wide|sideways|status)\\s"
  content_items  <- Filter(function(x) !grepl(float_attr_pat, trimws(x)), content_items)
  all_text <- paste(unlist(content_items), collapse = " ")

  # ---- Extract caption from @@@CAP@@@ marker ----
  cap_m <- regmatches(all_text, regexpr("@@@CAP@@@(.*?)@@@/CAP@@@", all_text, perl = TRUE))
  if (length(cap_m) > 0 && nchar(cap_m) > 0) {
    cap_inner <- sub("^@@@CAP@@@", "", sub("@@@/CAP@@@$", "", cap_m))
    # Extract LyX figure label from within the caption (for chunk ID)
    lbl_m <- regmatches(cap_inner, regexpr("@@@LABEL@@@(.*?)@@@/LABEL@@@", cap_inner, perl = TRUE))
    lyx_fig_label <- if (length(lbl_m) > 0 && nchar(lbl_m) > 0)
      sub("^@@@LABEL@@@", "", sub("@@@/LABEL@@@$", "", lbl_m)) else ""
    # Remove label marker from caption text
    cap_inner <- trimws(gsub("@@@LABEL@@@.*?@@@/LABEL@@@", "", cap_inner, perl = TRUE))
    caption <- cap_inner
  } else {
    # Fallback: derive caption from all_text (old behaviour, strip FIGFILE + markers)
    caption <- gsub("@@@[^@]+@@@", " ", all_text, perl = TRUE)
    caption <- str_replace_all(caption, "FIGFILE:[^:]+:FIGFILE", "")
    caption <- str_replace_all(caption, "\\s+", " ")
    caption <- trimws(caption)
    lyx_fig_label <- ""
  }
  # Fallback: label may be in a separate layout outside the caption
  if (nchar(lyx_fig_label) == 0) {
    lbl_m2 <- regmatches(all_text, regexpr("@@@LABEL@@@(.*?)@@@/LABEL@@@", all_text, perl = TRUE))
    if (length(lbl_m2) > 0 && nchar(lbl_m2) > 0)
      lyx_fig_label <- sub("^@@@LABEL@@@", "", sub("@@@/LABEL@@@$", "", lbl_m2))
  }
  caption <- str_replace_all(caption, "\\s+", " ")
  caption <- trimws(caption)
  caption <- gsub('"', "'", caption)
  caption <- gsub("\\\\", "\\\\\\\\", caption)

  # ---- Find FIGFILE markers (may be multiple for side-by-side images) ----
  fig_matches <- str_extract_all(all_text, "FIGFILE:[^:]+:FIGFILE")[[1]]
  if (length(fig_matches) == 0) return("")
  filenames <- trimws(sub("FIGFILE:(.+):FIGFILE", "\\1", fig_matches))

  base_fn  <- basename(filenames[1])

  # Only treat as callout box if the figure has no cross-reference label
  if (grepl("^box[0-9]", base_fn) && nchar(lyx_fig_label) == 0) {
    return(paste0("\n\n<!-- Callout box figure: ", base_fn, " -->\n\n"))
  }

  # Chunk ID: prefer LyX figure label, fall back to first filename
  chunk_id <- if (nchar(lyx_fig_label) > 0) {
    make_label(sub("^fig:", "", lyx_fig_label))
  } else {
    gsub("[^a-zA-Z0-9]", "-", gsub("\\.(pdf|png|jpg|jpeg)$", "", base_fn))
  }

  png_fns <- sub("\\.(pdf|PDF)$", ".png", basename(filenames))
  # For labeled multi-image floats use only the first image so bookdown creates
  # a single figure ID matching the cross-reference label.
  fig_code <- paste0('knitr::include_graphics("figures/', png_fns[1], '")\n')

  fig_width <- if (!is.null(FIG_WIDTH_OVERRIDES[[chunk_id]])) FIG_WIDTH_OVERRIDES[[chunk_id]] else "71%"

  paste0(
    '\n\n```{r ', chunk_id, ', echo=FALSE, out.width="', fig_width, '"',
    if (nchar(caption) > 0) paste0(', fig.cap="', caption, '"') else "",
    '}\n',
    fig_code,
    '```\n\n'
  )
}

# Parse tabular: extract cell values and format as markdown table
parse_tabular <- function(raw_lines, content_items) {
  # Extract number of rows and columns from XML header
  hdr <- grep("lyxtabular version", raw_lines, value = TRUE)
  n_rows <- 1; n_cols <- 1
  if (length(hdr) > 0) {
    rm <- regmatches(hdr[1], regexpr('rows="(\\d+)"', hdr[1]))
    cm <- regmatches(hdr[1], regexpr('columns="(\\d+)"', hdr[1]))
    if (length(rm) > 0) n_rows <- as.integer(sub('rows="(\\d+)"', "\\1", rm))
    if (length(cm) > 0) n_cols <- as.integer(sub('columns="(\\d+)"', "\\1", cm))
  }

  # Keep only rendered cell values (non-XML, non-LyX, non-empty)
  cells <- Filter(function(x) {
    x2 <- trimws(x)
    nchar(x2) > 0 &&
      !grepl("^<[a-zA-Z/]", x2) &&
      !grepl("^\\\\[a-zA-Z]", x2) &&
      !grepl("^(status|placement|alignment|wide|sideways|version)\\b", x2)
  }, unlist(content_items))

  if (length(cells) == 0) return("")

  # Build a simple markdown table
  rows_list <- split(cells, ceiling(seq_along(cells) / n_cols))
  lines_out <- character(0)
  for (ridx in seq_along(rows_list)) {
    row_cells <- rows_list[[ridx]]
    # Pad to n_cols if needed
    while (length(row_cells) < n_cols) row_cells <- c(row_cells, "")
    lines_out <- c(lines_out, paste0("| ", paste(row_cells, collapse = " | "), " |"))
    if (ridx == 1) {
      lines_out <- c(lines_out, paste0("| ", paste(rep("---", n_cols), collapse = " | "), " |"))
    }
  }
  paste0("\n\n", paste(lines_out, collapse = "\n"), "\n\n")
}

# Extract a table from float content
render_float_table <- function(raw_lines, content_items) {
  float_attr_pat <- "^(placement|alignment|wide|sideways|status)\\s"
  content_items  <- Filter(function(x) !grepl(float_attr_pat, trimws(x)), content_items)
  all_text <- paste(unlist(content_items), collapse = " ")

  caption <- ""
  lyx_tab_label <- ""
  cap_m <- regmatches(all_text, regexpr("@@@CAP@@@(.*?)@@@/CAP@@@", all_text, perl = TRUE))
  if (length(cap_m) > 0 && nchar(cap_m) > 0) {
    cap_inner <- sub("^@@@CAP@@@", "", sub("@@@/CAP@@@$", "", cap_m))
    lbl_m <- regmatches(cap_inner, regexpr("@@@LABEL@@@(.*?)@@@/LABEL@@@", cap_inner, perl = TRUE))
    lyx_tab_label <- if (length(lbl_m) > 0 && nchar(lbl_m) > 0)
      sub("^@@@LABEL@@@", "", sub("@@@/LABEL@@@$", "", lbl_m)) else ""
    caption <- trimws(gsub("@@@LABEL@@@.*?@@@/LABEL@@@", "", cap_inner, perl = TRUE))
  }
  if (nchar(lyx_tab_label) == 0) {
    lbl_m2 <- regmatches(all_text, regexpr("@@@LABEL@@@(.*?)@@@/LABEL@@@", all_text, perl = TRUE))
    if (length(lbl_m2) > 0 && nchar(lbl_m2) > 0)
      lyx_tab_label <- sub("^@@@LABEL@@@", "", sub("@@@/LABEL@@@$", "", lbl_m2))
  }
  caption <- trimws(str_replace_all(caption, "\\s+", " "))

  table_text <- gsub("@@@CAP@@@.*?@@@/CAP@@@", "", all_text, perl = TRUE)
  table_text <- gsub("@@@LABEL@@@.*?@@@/LABEL@@@", "", table_text, perl = TRUE)
  table_text <- gsub("@@@[^@]+@@@", "", table_text, perl = TRUE)
  table_text <- trimws(table_text)

  tab_id <- if (nchar(lyx_tab_label) > 0) make_label(sub("^tab:", "", lyx_tab_label)) else ""

  cap_line <- if (nchar(caption) > 0 || nchar(tab_id) > 0)
    paste0("Table: ", caption,
           if (nchar(tab_id) > 0) paste0(" (\\#tab:", tab_id, ")") else "")
  else ""

  paste0("\n\n",
         if (nchar(cap_line) > 0) paste0(cap_line, "\n\n") else "",
         table_text, "\n\n")
}

make_label <- function(s) {
  s <- iconv(s, to = "ASCII//TRANSLIT", sub = "-")  # å→a, ä→a, ö→o etc.
  s <- tolower(s)
  s <- gsub("[^a-z0-9]+", "-", s)
  s <- gsub("^-+|-+$", "", s)
  s
}

# ==============================================================
# render_layout: convert layout + rendered content to Markdown
# ==============================================================
render_layout <- function(name, content_items, depth = 0) {
  # Process text parts (handle bold/italic markers, skip LyX commands)
  text <- render_text_parts(content_items)
  text <- str_replace_all(text, "[ \t]+", " ")
  text <- trimws(text)

  if (nchar(text) == 0) return("")

  # Extract label (@@@LABEL@@@...@@@/LABEL@@@): eq → inject into equation; fig/tab → preserve for float renderer; others → heading anchor
  heading_id <- ""
  if (grepl("@@@LABEL@@@", text, fixed = TRUE)) {
    lbl_m <- regmatches(text, regexpr("@@@LABEL@@@(.*?)@@@/LABEL@@@", text, perl = TRUE))
    if (length(lbl_m) > 0 && nchar(lbl_m) > 0) {
      lyx_lbl <- sub("^@@@LABEL@@@", "", sub("@@@/LABEL@@@$", "", lbl_m))
      if (grepl("^eq:", lyx_lbl)) {
        eq_id <- make_label(sub("^eq:", "", lyx_lbl))
        tag   <- paste0(" (\\#eq:", eq_id, ")")
        if (grepl("\\\\end\\{", text, perl = TRUE)) {
          m <- gregexpr("\\\\end\\{[^}]+\\}", text, perl = TRUE)[[1]]
          if (!is.na(m[1])) {
            last_pos <- tail(m, 1)
            text <- paste0(substr(text, 1, last_pos - 1), tag, " ",
                           substr(text, last_pos, nchar(text)))
          }
        } else {
          m <- gregexpr("\n\\$\\$", text)[[1]]
          if (!is.na(m[1])) {
            last_pos <- tail(m, 1)
            text <- paste0(substr(text, 1, last_pos - 1), tag,
                           substr(text, last_pos, nchar(text)))
          }
        }
        text <- trimws(gsub("@@@LABEL@@@.*?@@@/LABEL@@@", "", text, perl = TRUE))
      } else if (grepl("^(fig:|tab:)", lyx_lbl)) {
        # Float label: preserve the full @@@LABEL@@@...@@@/LABEL@@@ marker so it
        # propagates through Caption → render_float_figure/render_float_table
      } else {
        heading_id <- paste0(" {#", make_label(lyx_lbl), "}")
        text <- trimws(gsub("@@@LABEL@@@.*?@@@/LABEL@@@", "", text, perl = TRUE))
      }
    }
  }
  # Strip stray markers — preserve @@@CAP@@@ and @@@LABEL@@@ (needed by float renderers)
  text <- gsub("@@@(?!/?CAP)(?!/?LABEL)[A-Z/]+@@@", "", text, perl = TRUE)
  text <- trimws(str_replace_all(text, "[ \t]+", " "))
  if (nchar(text) == 0) return("")

  indent       <- paste(rep("    ", depth), collapse = "")
  enum_markers <- c("1.", "a.", "i.", "A.")
  list_marker  <- enum_markers[min(depth + 1, length(enum_markers))]

  switch(name,
    "Part"           = ,
    "Part*"          = paste0("\n\n# (PART) ", text, " {-}\n\n"),
    "Chapter"        = paste0("\n# ", text, heading_id, "\n"),
    "Chapter*"       = paste0("\n# ", text, " {-}\n"),
    "Section"        = paste0("\n## ", text, heading_id, "\n"),
    "Section*"       = paste0("\n## ", text, " {-}\n"),
    "Subsection"     = paste0("\n### ", text, heading_id, "\n"),
    "Subsection*"    = paste0("\n### ", text, " {-}\n"),
    "Subsubsection"  = paste0("\n#### ", text, heading_id, "\n"),
    "Subsubsection*" = paste0("\n#### ", text, " {-}\n"),
    "Paragraph"      = ,
    "Paragraph*"     = paste0("\n#### ", text, "\n"),
    "Standard"       = paste0("\n", text, "\n"),
    "Itemize"        = paste0("\n", indent, "- ", text),
    "Enumerate"      = paste0("\n", indent, list_marker, " ", text),
    "Description"    = paste0("\n\n**", text, "**\n"),
    "Plain Layout"   = text,
    "LyX-Code"       = paste0("\n\n```\n", text, "\n```\n\n"),
    # Default
    paste0("\n", text, "\n")
  )
}

render_text_parts <- function(items) {
  parts  <- character(0)
  bold   <- FALSE
  italic <- FALSE

  for (item in unlist(items)) {
    t <- trimws(item)

    if (t == "\\series bold")                                           { if (!bold)   { parts <- c(parts, "**"); bold   <- TRUE  }; next }
    if (t %in% c("\\series default","\\series medium","\\series normal")) { if (bold)    { parts <- c(parts, "**"); bold   <- FALSE }; next }
    if (t == "\\emph on")                                               { if (!italic) { parts <- c(parts, "*");  italic <- TRUE  }; next }
    if (t %in% c("\\emph default","\\emph off"))                        { if (italic)  { parts <- c(parts, "*");  italic <- FALSE }; next }

    # Skip all LyX backslash commands (any line starting with \ + letter)
    # Exception: keep lines that are pure LaTeX math or FIGFILE markers
    if (grepl("^\\\\[a-zA-Z]", t) && !grepl("^FIGFILE:", t)) next
    # Skip XML / HTML tag lines (from tabular)
    if (grepl("^<[a-zA-Z/]", t)) next
    # Skip Float / inset attribute lines
    if (grepl("^(status|placement|alignment|wide|sideways|range|pageformat|LatexCommand|name|reference|key|plural|caps|noprefix|nolink|filename|version|rotate)\\s", t)) next
    # Skip empty lines (just add a space to preserve word boundary)
    if (nchar(t) == 0) { parts <- c(parts, " "); next }

    parts <- c(parts, item)
  }

  # Close unclosed formatting
  if (bold)   parts <- c(parts, "**")
  if (italic) parts <- c(parts, "*")

  # Join parts: add space at text→math boundary (word char runs into opening $)
  result <- ""
  for (p in parts) {
    if (nchar(result) == 0) {
      result <- p
    } else if (nchar(p) > 0) {
      last_ch  <- substr(result, nchar(result), nchar(result))
      first_ch <- substr(p, 1, 1)
      if (grepl("[a-zA-Z0-9,;:]", last_ch) && first_ch == "$") {
        result <- paste0(result, " ", p)
      } else {
        result <- paste0(result, p)
      }
    }
  }
  # Remove empty emphasis toggles (stray LyX markers)
  result <- gsub("\\*\\*\\s*\\*\\*", "", result)
  result <- gsub("(?<!\\*)\\*\\s*\\*(?!\\*)", "", result, perl = TRUE)
  result
}

# ==============================================================
# parse_section: main parser for a range of lines
# Returns Markdown text
# ==============================================================
parse_section <- function(lines) {
  stack        <- list()  # each: list(type, name, content, depth)
  result_parts <- list()
  list_depth   <- 0  # incremented by \begin_deeper, decremented by \end_deeper

  push <- function(type, name, depth = 0) {
    stack[[length(stack) + 1]] <<- list(type = type, name = name, content = list(), depth = depth)
  }
  add_to_top <- function(item) {
    if (length(stack) == 0) return()
    stack[[length(stack)]]$content <<- c(stack[[length(stack)]]$content, list(item))
  }
  pop_layout <- function() {
    # Pop the top layout from the stack
    if (length(stack) == 0) return()
    top_idx <- length(stack)
    if (stack[[top_idx]]$type != "layout") return()
    item <- stack[[top_idx]]
    stack[[top_idx]] <<- NULL
    if (length(stack) == 0) stack <<- list()
    else stack <<- stack[seq_len(top_idx - 1)]
    rendered <- render_layout(item$name, item$content, item$depth)
    if (length(stack) > 0) {
      add_to_top(rendered)
    } else {
      result_parts[[length(result_parts) + 1]] <<- rendered
      result_parts[[length(result_parts) + 1]] <<- "\n"  # ensure blank line between top-level blocks
    }
  }
  pop_inset <- function() {
    if (length(stack) == 0) return()
    top_idx <- length(stack)
    if (stack[[top_idx]]$type != "inset") return()
    item <- stack[[top_idx]]
    stack[[top_idx]] <<- NULL
    if (length(stack) == 0) stack <<- list()
    else stack <<- stack[seq_len(top_idx - 1)]
    rendered <- render_inset(item$name, item$content)
    if (length(stack) > 0) {
      add_to_top(rendered)
    } else {
      result_parts[[length(result_parts) + 1]] <<- rendered
    }
  }

  for (line in lines) {
    if (grepl("^\\\\begin_deeper\\s*$", line)) {
      list_depth <- list_depth + 1
    } else if (grepl("^\\\\end_deeper\\s*$", line)) {
      list_depth <- max(0L, list_depth - 1L)
    } else if (grepl("^\\\\begin_layout (.+)$", line)) {
      lname <- sub("^\\\\begin_layout (.+)$", "\\1", line)
      push("layout", lname, list_depth)
    } else if (grepl("^\\\\end_layout\\s*$", line)) {
      pop_layout()
    } else if (grepl("^\\\\begin_inset (.+)$", line)) {
      ispec <- sub("^\\\\begin_inset (.+)$", "\\1", line)
      push("inset", ispec)
    } else if (grepl("^\\\\end_inset\\s*$", line)) {
      pop_inset()
    } else if (grepl("^\\\\begin_body\\s*$", line) || grepl("^\\\\end_body\\s*$", line)) {
      # ignore body markers
    } else {
      add_to_top(line)
    }
  }

  # Flush remaining items (shouldn't happen in well-formed LyX)
  while (length(stack) > 0) {
    top <- stack[[length(stack)]]
    stack[[length(stack)]] <<- NULL
    if (length(stack) == 0) stack <<- list()
    if (top$type == "layout") {
      result_parts[[length(result_parts) + 1]] <- render_layout(top$name, top$content)
    }
  }

  output <- paste(unlist(result_parts), collapse = "")
  # Clean up excessive blank lines
  output <- gsub("\n{3,}", "\n\n", output, perl = TRUE)
  trimws(output)
}

# ==============================================================
# Interactive exercises: find, extract, and render exercises sections
# with collapsible solutions block
# ==============================================================

# Returns list of (start, end) relative index pairs for "Exercises" Sections
find_exercises_ranges <- function(chapter_lines) {
  n      <- length(chapter_lines)
  ranges <- list()
  i      <- 1
  while (i <= n) {
    s <- trimws(chapter_lines[i])
    if (s == "\\begin_layout Section") {
      j <- i + 1
      while (j <= n && nchar(trimws(chapter_lines[j])) == 0) j <- j + 1
      if (j <= n && trimws(chapter_lines[j]) == "Exercises") {
        # Find where this section ends (next Section/Chapter layout or end)
        end_idx <- n
        for (k in (j + 1):n) {
          t <- trimws(chapter_lines[k])
          if (grepl("^\\\\begin_layout (Section|Chapter)", t)) {
            end_idx <- k - 1
            break
          }
        }
        ranges <- c(ranges, list(list(start = i, end = end_idx)))
        i <- end_idx + 1
        next
      }
    }
    i <- i + 1
  }
  ranges
}

# ---- helpers for JS-based per-question exercise rendering ----

# Convert $...$ and $$...$$ to MathJax notation \(...\) / \[...\]
md_math_to_mathjax <- function(s) {
  s <- gsub("\\$\\$([^$]+)\\$\\$", "\\\\[\\1\\\\]", s)
  s <- gsub("\\$([^$\n]+)\\$",     "\\\\(\\1\\\\)", s)
  s
}

# Convert a single parse_section() output (one list item) to an HTML snippet
md_to_exercise_html <- function(md) {
  md <- trimws(md)
  if (nchar(md) == 0) return("")
  md <- sub("^\\d+\\.\\s*", "", md)          # strip leading "1. "
  md <- sub("^[a-z]\\.\\s*", "", md)         # strip leading "a. "
  lines  <- strsplit(md, "\n")[[1]]
  result <- character(0)
  in_list <- FALSE
  i <- 1L

  # Collect a $$...$$ block; i points to opening "$$" on entry, exits past closing "$$"
  collect_display <- function() {
    math_lines <- character(0)
    i <<- i + 1L
    while (i <= length(lines) && trimws(lines[i]) != "$$") {
      math_lines <- c(math_lines, lines[i])
      i <<- i + 1L
    }
    body <- paste(trimws(math_lines[nchar(trimws(math_lines)) > 0]), collapse = " ")
    paste0("\\(\\displaystyle ", body, "\\)")
  }

  while (i <= length(lines)) {
    line <- lines[i]
    lt   <- trimws(line)
    if (nchar(lt) == 0) { i <- i + 1L; next }

    if (grepl("^    [a-zA-Z1-9]\\.", line)) {
      if (!in_list) { result <- c(result, '<ol type="a">'); in_list <- TRUE }
      item <- trimws(sub("^\\s+[a-zA-Z1-9]\\.\\s*", "", line))

      if (item == "$$") {
        # Entire item is a display block
        item <- collect_display()
      } else if (nchar(item) == 0) {
        # Empty item: display block may follow
        j <- i + 1L
        while (j <= length(lines) && nchar(trimws(lines[j])) == 0) j <- j + 1L
        if (j <= length(lines) && trimws(lines[j]) == "$$") { i <- j; item <- collect_display() }
      } else {
        item <- md_math_to_mathjax(item)
        # Text item may be followed immediately by a display block (e.g. "for \[\cases\]")
        j <- i + 1L
        while (j <= length(lines) && nchar(trimws(lines[j])) == 0) j <- j + 1L
        if (j <= length(lines) && trimws(lines[j]) == "$$") {
          i <- j
          item <- paste0(item, collect_display())
        }
      }
      result <- c(result, paste0("<li>", item, "</li>"))

    } else {
      if (in_list) { result <- c(result, "</ol>"); in_list <- FALSE }
      if (lt == "$$") {
        # Display math block in paragraph context
        result <- c(result, paste0("<p>", collect_display(), "</p>"))
      } else {
        result <- c(result, paste0("<p>", md_math_to_mathjax(lt), "</p>"))
      }
    }
    i <- i + 1L
  }
  if (in_list) result <- c(result, "</ol>")
  paste(result, collapse = "")
}

# Escape an HTML string for embedding in a single-quoted JS string literal
escape_for_js <- function(s) {
  s <- gsub("\\\\", "\\\\\\\\", s)  # \ → \\
  s <- gsub("'",    "\\\\'",    s)  # ' → \'
  s <- gsub("[\r\n]", " ",      s)  # newlines → space
  s
}

# Extract top-level list blocks (one block = depth-0 Enumerate + any following begin_deeper)
extract_list_blocks <- function(lyx_lines) {
  blocks   <- list()
  cur      <- NULL
  depth    <- 0L
  for (line in lyx_lines) {
    s <- trimws(line)
    if (s == "\\begin_deeper") {
      depth <- depth + 1L
      if (!is.null(cur)) cur <- c(cur, line)
    } else if (s == "\\end_deeper") {
      depth <- max(0L, depth - 1L)
      if (!is.null(cur)) cur <- c(cur, line)
    } else if ((s == "\\begin_layout Enumerate" || s == "\\begin_layout Itemize") && depth == 0L) {
      if (!is.null(cur) && length(cur) > 0) blocks <- c(blocks, list(cur))
      cur <- line
    } else {
      if (!is.null(cur)) cur <- c(cur, line)
    }
  }
  if (!is.null(cur) && length(cur) > 0) blocks <- c(blocks, list(cur))
  blocks
}

.ex_counter <- 0L  # unique ID counter for exercise containers

render_exercises_section <- function(sec_lines) {
  n <- length(sec_lines)

  # Find "Solutions:" Subsubsection
  sol_idx <- NA
  i <- 1
  while (i < n) {
    if (trimws(sec_lines[i]) == "\\begin_layout Subsubsection") {
      j <- i + 1
      while (j <= n && nchar(trimws(sec_lines[j])) == 0) j <- j + 1
      if (j <= n && grepl("^Solutions", trimws(sec_lines[j]))) { sol_idx <- i; break }
    }
    i <- i + 1
  }
  if (is.na(sol_idx)) return(parse_section(sec_lines))

  # Skip "Exercises" section heading
  heading_end <- 1
  for (i in 2:min(20, n)) {
    if (trimws(sec_lines[i]) == "\\end_layout") { heading_end <- i; break }
  }
  q_lines <- sec_lines[(heading_end + 1):(sol_idx - 1)]

  # Skip "Solutions:" subsubsection heading
  sol_end <- sol_idx
  for (i in (sol_idx + 1):min(sol_idx + 15, n)) {
    if (trimws(sec_lines[i]) == "\\end_layout") { sol_end <- i; break }
  }
  a_lines <- if (sol_end < n) sec_lines[(sol_end + 1):n] else character(0)

  # Individual blocks
  q_blocks <- extract_list_blocks(q_lines)
  a_blocks <- extract_list_blocks(a_lines)
  n_q <- length(q_blocks)
  if (n_q == 0) return(parse_section(sec_lines))

  # Convert each block to HTML
  q_htmls <- vapply(q_blocks, function(b) md_to_exercise_html(parse_section(b)), character(1))
  a_htmls <- vapply(seq_len(n_q), function(i) {
    if (i <= length(a_blocks)) md_to_exercise_html(parse_section(a_blocks[[i]])) else ""
  }, character(1))

  # Unique container ID
  .ex_counter <<- .ex_counter + 1L
  cid <- paste0("ex-", .ex_counter)

  # Build JS items array
  items_js <- paste(vapply(seq_len(n_q), function(i) {
    paste0("  {q:'", escape_for_js(q_htmls[i]), "',a:'", escape_for_js(a_htmls[i]), "'}")
  }, character(1)), collapse = ",\n")

  paste0(
    "\n## Exercises\n\n",
    '<div id="', cid, '" class="exercises-container"></div>\n',
    '<script>\n',
    '(function(){\n',
    'var ex=[\n', items_js, '\n];\n',
    'var c=document.getElementById("', cid, '");\n',
    'if(!c)return;\n',
    'var h=\'<ol class="exercise-list">\';\n',
    'ex.forEach(function(e){\n',
    '  h+=\'<li class="exercise-item">\';\n',
    '  h+=\'<div class="exercise-question">\'+e.q+\'</div>\';\n',
    '  if(e.a){\n',
    '    h+=\'<details class="exercise-answer">\';\n',
    '    h+=\'<summary>Show answer &#9654;</summary>\';\n',
    '    h+=\'<div class="answer-content">\'+e.a+\'</div>\';\n',
    '    h+=\'</details>\';\n',
    '  }\n',
    '  h+=\'</li>\';\n',
    '});\n',
    'h+=\'</ol>\';\n',
    'c.innerHTML=h;\n',
    'function fixMathAlign(el){\n',
    '  el.querySelectorAll(".MathJax_Display").forEach(function(d){\n',
    '    d.style.textAlign="left";\n',
    '    d.style.marginLeft="1.5em";\n',
    '  });\n',
    '}\n',
    'if(window.MathJax){\n',
    '  if(MathJax.Hub){\n',
    '    MathJax.Hub.Queue(["Typeset",MathJax.Hub,c]);\n',
    '    MathJax.Hub.Queue(function(){fixMathAlign(c);});\n',
    '  } else if(MathJax.typesetPromise){\n',
    '    MathJax.typesetPromise([c]).then(function(){fixMathAlign(c);});\n',
    '  }\n',
    '}\n',
    'c.querySelectorAll("details").forEach(function(d){\n',
    '  d.addEventListener("toggle",function(){\n',
    '    if(d.open&&window.MathJax){\n',
    '      if(MathJax.Hub){\n',
    '        MathJax.Hub.Queue(["Typeset",MathJax.Hub,d]);\n',
    '        MathJax.Hub.Queue(function(){fixMathAlign(d);});\n',
    '      } else if(MathJax.typesetPromise){\n',
    '        MathJax.typesetPromise([d]).then(function(){fixMathAlign(d);});\n',
    '      }\n',
    '    }\n',
    '  });\n',
    '});\n',
    '})();\n',
    '</script>\n\n'
  )
}

# Wrapper: uses render_exercises_section for Exercises sections, parse_section elsewhere
process_chapter <- function(chapter_lines) {
  ex_ranges <- find_exercises_ranges(chapter_lines)
  if (length(ex_ranges) == 0) return(parse_section(chapter_lines))

  segments  <- list()
  prev_end  <- 0
  for (r in ex_ranges) {
    if (r$start > prev_end + 1)
      segments <- c(segments, list(list(type = "normal",    lines = chapter_lines[(prev_end + 1):(r$start - 1)])))
    segments <- c(segments, list(list(type = "exercises", lines = chapter_lines[r$start:r$end])))
    prev_end <- r$end
  }
  nl <- length(chapter_lines)
  if (prev_end < nl)
    segments <- c(segments, list(list(type = "normal", lines = chapter_lines[(prev_end + 1):nl])))

  parts <- vapply(segments, function(seg) {
    if (seg$type == "normal") parse_section(seg$lines) else render_exercises_section(seg$lines)
  }, character(1))

  paste(parts, collapse = "\n\n")
}

# ==============================================================
# Find chapter and part boundaries
# ==============================================================
chapter_lines  <- which(grepl("^\\\\begin_layout Chapter$",  lines))
chapter_star   <- which(grepl("^\\\\begin_layout Chapter\\*$", lines))
part_lines     <- which(grepl("^\\\\begin_layout Part",       lines))
end_body_line  <- which(grepl("^\\\\end_body",                lines))[1]

message("Chapter starts at lines: ", paste(chapter_lines, collapse=", "))

# Preface: Chapter* at line ~383
preface_start <- chapter_star[1]
ch1_start     <- chapter_lines[1]
# Chapter boundaries: preface + Part I (ch1-14) + Part II (ch15-20)
ch_starts <- c(preface_start, chapter_lines[1:20])
ch_ends   <- c(chapter_lines[1]  - 1,
               chapter_lines[2]  - 1,
               chapter_lines[3]  - 1,
               chapter_lines[4]  - 1,
               chapter_lines[5]  - 1,
               chapter_lines[6]  - 1,
               chapter_lines[7]  - 1,
               chapter_lines[8]  - 1,
               chapter_lines[9]  - 1,
               chapter_lines[10] - 1,
               chapter_lines[11] - 1,
               chapter_lines[12] - 1,
               chapter_lines[13] - 1,
               chapter_lines[14] - 1,
               chapter_lines[15] - 1,
               chapter_lines[16] - 1,
               chapter_lines[17] - 1,
               chapter_lines[18] - 1,
               chapter_lines[19] - 1,
               chapter_lines[20] - 1,
               chapter_lines[21] - 1)

# Chapter output files
out_files <- c(
  "index.Rmd",
  "01-why-math.Rmd",
  "02-basics.Rmd",
  "03-examples-applications.Rmd",
  "04-functions-graphs.Rmd",
  "05-logarithms.Rmd",
  "06-polynomial-equations.Rmd",
  "07-systems-linear-equations.Rmd",
  "08-theories-life-death-dating.Rmd",
  "09-nonlinear-equations-systems.Rmd",
  "10-derivative.Rmd",
  "11-optimization-functions.Rmd",
  "12-theories-cake-monopoly.Rmd",
  "13-integration.Rmd",
  "14-linear-algebra.Rmd",
  "15-counterfactual-analysis.Rmd",
  "16-variation-covariation.Rmd",
  "17-least-squares.Rmd",
  "18-covariation-social-science.Rmd",
  "19-least-squares-multiple-variables.Rmd",
  "20-regression-causal-relationships.Rmd"
)

# YAML headers for each file
yaml_headers <- list(
  "index.Rmd" = '---
title: "The Cheat Code: Essential Math and Statistics for Social Scientists"
author: "Erik Hegelund"
date: "`r Sys.Date()`"
site: bookdown::bookdown_site
documentclass: book
bibliography: references.bib
biblio-style: apalike
link-citations: yes
description: "A textbook in mathematics and statistics for social science students."
---

',
  default = ""
)

# ==============================================================
# Convert and write each chapter
# ==============================================================
for (i in seq_along(ch_starts)) {
  s <- ch_starts[i]
  e <- ch_ends[i]

  if (out_files[i] %in% LOCKED_CHAPTERS) {
    message("  Locked (skipping): ", out_files[i])
    next
  }

  message("Converting: ", out_files[i], " (lines ", s, "-", e, ")")

  section_lines <- lines[s:e]
  md_content    <- process_chapter(section_lines)

  # Build Rmd header
  if (out_files[i] == "index.Rmd") {
    header <- yaml_headers[["index.Rmd"]]
  } else {
    header <- ""
  }

  # Add setup chunk to each chapter file (not index)
  setup_chunk <- if (out_files[i] != "index.Rmd") {
    '\n```{r setup, include=FALSE}\nknitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE, fig.align = "left")\n```\n\n'
  } else {
    '\n```{r setup, include=FALSE}\nknitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE, fig.align = "left")\n```\n\n'
  }

  # Safety cleanup: strip any @@@LABEL@@@...@@@/LABEL@@@ that weren't consumed by float renderers
  md_content <- gsub("@@@LABEL@@@[^@]*@@@/LABEL@@@", "", md_content, perl = TRUE)
  full_content <- paste0(header, setup_chunk, md_content, "\n")

  writeLines(full_content, out_files[i], useBytes = FALSE)
  message("  Written: ", out_files[i])
}

message("\nDone! All ", length(out_files), " files written.")
