suppressPackageStartupMessages({ library(V8); library(jsonlite) })

# ── Convert HTML exercise strings to clean markdown for PDF output ────────────
html_to_md <- function(s) {
  if (is.null(s) || length(s) == 0 || is.na(s) || !nzchar(s)) return("")
  # <ol type="a"><li>...</li>...</ol>  →  (a) ...\n\n(b) ...
  while (grepl('<ol[^>]*>', s, perl = TRUE)) {
    m <- regexpr('<ol[^>]*>((?:.|\\n)*?)</ol>', s, perl = TRUE)
    if (m == -1L) break
    ol_html   <- regmatches(s, m)
    li_matches <- regmatches(ol_html,
                             gregexpr('<li[^>]*>((?:.|\\n)*?)</li>', ol_html, perl = TRUE))[[1]]
    items <- sub('<li[^>]*>((?:.|\\n)*?)</li>', '\\1', li_matches, perl = TRUE)
    labeled <- paste0("(", letters[seq_along(items)], ") ", trimws(items),
                      collapse = "\n\n")
    s <- sub('<ol[^>]*>(?:.|\\n)*?</ol>', labeled, s, perl = TRUE)
  }
  s <- gsub('<p>',           '',     s, fixed = TRUE)
  s <- gsub('</p>',          '\n\n', s, fixed = TRUE)
  s <- gsub('<br\\s*/?>',    '\n\n', s, perl  = TRUE)
  s <- gsub('<strong>(.*?)</strong>', '**\\1**', s, perl = TRUE)
  s <- gsub('<b>(.*?)</b>',  '**\\1**', s, perl = TRUE)
  s <- gsub('<[^>]+>',       '',     s, perl  = TRUE)
  s <- gsub('&lt;',  '<',  s, fixed = TRUE)
  s <- gsub('&gt;',  '>',  s, fixed = TRUE)
  s <- gsub('&amp;', '&',  s, fixed = TRUE)
  s <- gsub('&nbsp;',' ',  s, fixed = TRUE)
  s <- gsub('&#39;', "'",  s, fixed = TRUE)
  s <- gsub('[ \t]+',    ' ',  s, perl = TRUE)
  s <- gsub('\n{3,}', '\n\n', s, perl = TRUE)
  sub('^[[:space:]]+', '', s)   # strip leading whitespace only
}

# ── Helper: extract var ex=[...] and build PDF R-chunk lines ──────────────────
extract_and_build_chunk <- function(block, fname, div_id) {
  sc_start <- which(grepl("^<script>$",  block)) + 1L
  sc_end   <- which(grepl("^</script>$", block)) - 1L
  if (!length(sc_start) || !length(sc_end) || sc_start > sc_end)
    return(character(0))

  sc_lines <- block[sc_start:sc_end]
  ex_start <- which(grepl("^\\s*var \\w+\\s*=\\s*\\[", sc_lines))
  ex_js <- NULL; ex_var <- NULL
  if (length(ex_start)) {
    sl     <- sc_lines[ex_start[1]]
    ex_var <- sub("^\\s*var (\\w+)\\s*=.*", "\\1", sl)
    if (grepl("\\];\\s*$", sl)) {
      ex_js <- sl
    } else {
      for (k in seq(ex_start[1] + 1L, length(sc_lines))) {
        if (grepl("^\\s*\\];\\s*$", sc_lines[k])) {
          ex_js <- paste(sc_lines[ex_start[1]:k], collapse = "\n"); break
        }
      }
    }
  }

  ex_data <- NULL
  if (!is.null(ex_js) && !is.null(ex_var)) {
    ctx <- v8()
    tryCatch({
      ctx$eval(ex_js)
      ex_data <- fromJSON(ctx$eval(paste0("JSON.stringify(", ex_var, ")")),
                          simplifyVector = FALSE)
    }, error = function(e) message("  V8 error: ", e$message))
  }
  if (is.null(ex_data) || !length(ex_data)) return(character(0))

  get_field <- function(item, ...) {
    for (key in list(...)) {
      v <- item[[key]]
      if (!is.null(v) && length(v) > 0 && !is.na(v)) return(as.character(v))
    }
    ""
  }

  base_name  <- gsub("[^a-z0-9]", "_", tolower(sub("\\.Rmd$", "", fname)))
  id_clean   <- gsub("[^a-z0-9]", "_", div_id)
  chunk_name <- paste0(base_name, "_", id_clean, "_pdf")

  items_code <- vapply(ex_data, function(item) {
    q <- html_to_md(get_field(item, "q", "question"))
    a <- html_to_md(get_field(item, "a", "answer"))
    paste0("    list(\n      q = ", deparse(q), ",\n      a = ", deparse(a), "\n    )")
  }, character(1))

  c(
    paste0("```{r ", chunk_name, ", echo=FALSE, results='asis'}"),
    "if (knitr::is_latex_output()) {",
    "  ex_items <- list(",
    paste(items_code, collapse = ",\n"),
    "  )",
    "  for (i in seq_along(ex_items)) {",
    "    cat(\"**\", i, \".** \", ex_items[[i]]$q, \"\\n\\n\", sep=\"\")",
    "    if (nzchar(trimws(ex_items[[i]]$a)))",
    "      cat(\"*Answer:* \", ex_items[[i]]$a, \"\\n\\n\", sep=\"\")",
    "  }",
    "}",
    "```",
    ""
  )
}

# ── Remove existing _pdf R-chunk from tail of new_lines ───────────────────────
remove_existing_pdf_chunk <- function(nl) {
  k <- length(nl)
  while (k >= 1L && nl[k] == "") k <- k - 1L
  if (k < 1L || !grepl('^```$', nl[k])) return(nl)
  end_idx   <- k
  start_idx <- k - 1L
  while (start_idx >= 1L && !grepl('^```\\{r ', nl[start_idx])) start_idx <- start_idx - 1L
  if (start_idx >= 1L && grepl('_pdf', nl[start_idx])) {
    nl <- nl[seq_len(start_idx - 1L)]
    while (length(nl) > 0 && nl[length(nl)] == "") nl <- nl[-length(nl)]
    nl <- c(nl, "")
  }
  nl
}

# ── Main processing function ──────────────────────────────────────────────────
process_chapter <- function(fname) {
  nbytes <- file.info(fname)$size
  raw    <- readBin(fname, "raw", n = nbytes)
  text   <- rawToChar(raw)
  Encoding(text) <- "UTF-8"
  crlf   <- grepl("\r\n", text, fixed = TRUE)
  text_n <- if (crlf) gsub("\r\n", "\n", text, fixed = TRUE) else text
  lines  <- strsplit(text_n, "\n", fixed = TRUE)[[1]]

  i <- 1L; new_lines <- character(0); modified <- FALSE

  while (i <= length(lines)) {
    line <- lines[i]

    # ── Case A: raw unwrapped exercise div ─────────────────────────────────────
    is_raw_div      <- grepl('^<div id="ex-', line)
    already_wrapped <- i > 1L && grepl('^```\\{=html\\}', lines[i - 1L])

    if (is_raw_div && !already_wrapped) {
      div_id <- sub('^<div id="([^"]+)".*', "\\1", line)
      block  <- character(0); j <- i
      while (j <= length(lines)) {
        block <- c(block, lines[j])
        if (grepl("^</script>", lines[j])) break
        j <- j + 1L
      }
      r_lines <- extract_and_build_chunk(block, fname, div_id)
      new_lines <- c(new_lines, r_lines, "```{=html}", block, "```", "")
      i <- j + 1L; modified <- TRUE

    # ── Case B: {=html} block — add or replace PDF chunk ───────────────────────
    } else if (grepl('^```\\{=html\\}$', line)) {
      j <- i + 1L; block <- character(0); div_id <- NULL
      while (j <= length(lines)) {
        if (grepl('^```$', lines[j])) { block <- c(block, lines[j]); break }
        if (is.null(div_id) && grepl('^<div id="ex-', lines[j]))
          div_id <- sub('^<div id="([^"]+)".*', "\\1", lines[j])
        block <- c(block, lines[j]); j <- j + 1L
      }

      if (!is.null(div_id)) {
        inner_block <- block[seq_len(length(block) - 1L)]
        r_lines <- extract_and_build_chunk(inner_block, fname, div_id)
        if (length(r_lines)) {
          new_lines <- remove_existing_pdf_chunk(new_lines)
          new_lines <- c(new_lines, r_lines, line, block, "")
          i <- j + 1L; modified <- TRUE
        } else {
          new_lines <- c(new_lines, line); i <- i + 1L
        }
      } else {
        new_lines <- c(new_lines, line); i <- i + 1L
      }

    } else {
      new_lines <- c(new_lines, line); i <- i + 1L
    }
  }

  if (!modified) { message("No exercise blocks found: ", fname); return(invisible()) }
  new_text <- paste(new_lines, collapse = "\n")
  if (crlf) new_text <- gsub("\n", "\r\n", new_text, fixed = TRUE)
  writeBin(charToRaw(enc2utf8(new_text)), fname)
  message("Written: ", fname)
}

setwd("C:/Users/hegel/Dropbox/_MINA TEXTER _db/Matematik för samhällsvetare/The Cheat Code - text/bookdown-project")

chapters <- c(
  "02-basics.Rmd", "03-examples-applications.Rmd", "04-functions-graphs.Rmd",
  "05-logarithms.Rmd", "06-polynomial-equations.Rmd", "07-systems-linear-equations.Rmd",
  "08-theories-life-death-dating.Rmd", "09-nonlinear-equations-systems.Rmd",
  "10-derivative.Rmd", "11-optimization-functions.Rmd", "12-theories-cake-monopoly.Rmd",
  "13-integration.Rmd", "14-linear-algebra.Rmd", "15-counterfactual-analysis.Rmd",
  "16-probability-discrete.Rmd", "17-probability-continuous.Rmd",
  "18-probability-normal-t.Rmd", "19-statistical-inference.Rmd",
  "20-causality-covariation.Rmd", "21-least-squares.Rmd",
  "22-covariation-social-science.Rmd", "23-least-squares-multiple-variables.Rmd",
  "24-regression-statistical-tests.Rmd", "25-regression-multiple-tests.Rmd",
  "26-ols-conditions.Rmd", "27-regression-causal-relationships.Rmd"
)
for (ch in chapters) process_chapter(ch)
