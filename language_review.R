# language_review.R
# Grammar/spelling review of all chapter Rmd files using Claude API.
# - Minor fixes applied directly to files.
# - Major suggestions written to language_review_suggestions.md (NOT applied).
# - All changes logged to language_review_log.csv with ID, file and line number.
#   Use the ID to ask Claude to revert a specific change later.
#
# Requires: ANTHROPIC_API_KEY environment variable set.
# Run: Rscript language_review.R

library(tidyverse)
library(httr2)
library(jsonlite)

# ---- Config ----------------------------------------------------------------
API_KEY     <- Sys.getenv("ANTHROPIC_API_KEY")
MODEL       <- "claude-haiku-4-5-20251001"
BATCH_CHARS <- 2500
DELAY_SEC   <- 0.5
LOG_CSV     <- "language_review_log.csv"
SUGGEST_MD  <- "language_review_suggestions.md"

if (nchar(API_KEY) == 0) stop("ANTHROPIC_API_KEY not set.")

# ---- Extract prose paragraphs from Rmd ------------------------------------
extract_prose <- function(lines) {
  paras <- list()
  in_code <- FALSE
  in_display_math <- FALSE
  in_yaml <- length(lines) > 0 && grepl("^---\\s*$", lines[1])
  yaml_done <- FALSE
  cur <- c()
  cur_start <- 1L

  flush_para <- function(end_i) {
    if (length(cur) > 0) {
      paras[[length(paras) + 1]] <<- list(
        start = cur_start, end = end_i,
        text = paste(cur, collapse = "\n")
      )
      cur <<- c()
    }
  }

  for (i in seq_along(lines)) {
    ln <- lines[i]
    if (in_yaml && !yaml_done) {
      if (i > 1 && grepl("^---\\s*$", ln)) yaml_done <- TRUE
      next
    }
    if (grepl("^```", ln)) { in_code <- !in_code; flush_para(i - 1L); next }
    if (in_code) next
    n_dd <- lengths(regmatches(ln, gregexpr("\\$\\$", ln)))
    if (n_dd %% 2 != 0) in_display_math <- !in_display_math
    if (grepl("^\\$\\$", ln) || (in_display_math && n_dd == 0)) {
      flush_para(i - 1L); next
    }
    if (grepl("^\\s*$", ln)) { flush_para(i - 1L); next }
    if (grepl("^\\|", ln)) next
    if (length(cur) == 0) cur_start <- i
    cur <- c(cur, ln)
  }
  flush_para(length(lines))
  paras
}

# ---- Find line number of a string in file ----------------------------------
find_line_number <- function(lines, find_text) {
  for (i in seq_along(lines)) {
    if (grepl(find_text, lines[i], fixed = TRUE)) return(i)
  }
  # Multi-line: search in joined content
  content <- paste(lines, collapse = "\n")
  pos <- regexpr(find_text, content, fixed = TRUE)
  if (pos == -1) return(NA_integer_)
  # Count newlines before pos
  sum(strsplit(substr(content, 1, pos), "\n", fixed = TRUE)[[1]] != "")
}

# ---- Claude API call -------------------------------------------------------
SYSTEM_PROMPT <- paste0(
  "You are proofreading an academic mathematics textbook written in English. ",
  "Identify grammar and spelling errors ONLY.\n\n",
  "STRICT RULES:\n",
  "- Do NOT alter LaTeX math ($...$, $$...$$, \\begin{}, etc.)\n",
  "- Do NOT alter cross-references like \\@ref(...)\n",
  "- Do NOT change technical or mathematical terminology\n",
  "- Do NOT rewrite for style or clarity — only fix clear errors\n\n",
  "CLASSIFICATION:\n",
  "  minor = obvious typo or simple grammar fix (article, plural, verb form)\n",
  "  major = uncertain, or requires rewording more than 3 words\n\n",
  "OUTPUT: Return ONLY a JSON array, no other text:\n",
  '[{"find":"exact original text","replace":"corrected text",',
  '"type":"minor","reason":"brief note"}]\n',
  "If no errors: []"
)

call_claude <- function(text) {
  Sys.sleep(DELAY_SEC)
  tryCatch({
    resp <- request("https://api.anthropic.com/v1/messages") |>
      req_headers("x-api-key" = API_KEY, "anthropic-version" = "2023-06-01",
                  "content-type" = "application/json") |>
      req_body_json(list(model = MODEL, max_tokens = 1024,
                         system = SYSTEM_PROMPT,
                         messages = list(list(role = "user", content = text)))) |>
      req_error(is_error = \(r) FALSE) |>
      req_perform()
    if (resp_status(resp) != 200) { message("  API error ", resp_status(resp)); return(list()) }
    raw <- resp_body_json(resp)$content[[1]]$text
    m <- regmatches(raw, regexpr("\\[.*\\]", raw, perl = TRUE))
    if (length(m) == 0) return(list())
    fromJSON(m, simplifyVector = FALSE)
  }, error = function(e) { message("  Error: ", e$message); list() })
}

# ---- Apply fix -------------------------------------------------------------
apply_fix_to_lines <- function(lines, find, replace) {
  content <- paste(lines, collapse = "\n")
  if (!grepl(find, content, fixed = TRUE)) return(NULL)
  strsplit(sub(find, replace, content, fixed = TRUE), "\n", fixed = TRUE)[[1]]
}

# ---- Main loop -------------------------------------------------------------
rmd_files  <- sort(list.files(pattern = "^[0-9]+.*\\.Rmd$"))
log_rows   <- list()
suggestions <- list()
change_id  <- 0L

for (f in rmd_files) {
  cat(sprintf("Processing %s ...\n", f))
  lines    <- readLines(f, encoding = "UTF-8", warn = FALSE)
  paras    <- extract_prose(lines)
  modified <- FALSE
  batch_text <- ""

  for (pi in seq_along(paras)) {
    p <- paras[[pi]]
    if (nchar(p$text) < 15) next
    batch_text <- paste0(batch_text, "\n\n", p$text)

    if (nchar(batch_text) >= BATCH_CHARS || pi == length(paras)) {
      if (nchar(trimws(batch_text)) == 0) { batch_text <- ""; next }
      fixes <- call_claude(trimws(batch_text))
      batch_text <- ""

      for (fix in fixes) {
        if (!all(c("find", "replace", "type") %in% names(fix))) next
        if (fix$find == fix$replace) next

        change_id <- change_id + 1L
        line_nr   <- find_line_number(lines, fix$find)

        if (fix$type == "minor") {
          new_lines <- apply_fix_to_lines(lines, fix$find, fix$replace)
          if (!is.null(new_lines)) {
            lines <- new_lines; modified <- TRUE; status <- "applied"
          } else {
            status <- "not_found"
          }
        } else {
          status <- "suggested_only"
          suggestions[[length(suggestions) + 1]] <- c(fix, file = f,
                                                       id = change_id,
                                                       line = line_nr)
        }

        log_rows[[length(log_rows) + 1]] <- tibble(
          id      = change_id,
          file    = f,
          line    = if (is.na(line_nr)) "?" else as.character(line_nr),
          type    = fix$type,
          status  = status,
          find    = fix$find,
          replace = fix$replace,
          reason  = if (!is.null(fix$reason)) fix$reason else ""
        )
      }
    }
  }
  if (modified) writeLines(lines, f, useBytes = FALSE)
}

# ---- Write log CSV --------------------------------------------------------
if (length(log_rows) > 0) {
  log_df <- bind_rows(log_rows)
  write_csv(log_df, LOG_CSV)
  cat(sprintf("\nLog written to %s  (%d entries)\n", LOG_CSV, nrow(log_df)))
} else {
  cat("\nNo changes found.\n")
}

# ---- Write suggestions MD -------------------------------------------------
if (length(suggestions) > 0) {
  md <- c("# Language Review — Suggested Changes (NOT applied)", "",
          "Use the ID to reference a specific suggestion.", "")
  for (s in suggestions) {
    md <- c(md,
      sprintf("## Change #%s — %s (line %s)", s$id, s$file, s$line),
      sprintf("**Find:**    `%s`  ", s$find),
      sprintf("**Replace:** `%s`  ", s$replace),
      sprintf("**Reason:**  %s  ", if (!is.null(s$reason)) s$reason else ""),
      "")
  }
  writeLines(md, SUGGEST_MD)
  cat(sprintf("Suggestions: %s  (%d entries)\n", SUGGEST_MD, length(suggestions)))
}

cat("Done.\n")
