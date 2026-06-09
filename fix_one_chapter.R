suppressPackageStartupMessages({ library(V8); library(jsonlite) })

process_chapter <- function(fname) {
  # ── Read as raw bytes (preserves exact line endings) ─────────────────────
  nbytes <- file.info(fname)$size
  raw    <- readBin(fname, "raw", n = nbytes)
  text   <- rawToChar(raw)
  Encoding(text) <- "UTF-8"

  crlf   <- grepl("\r\n", text, fixed = TRUE)
  text_n <- if (crlf) gsub("\r\n", "\n", text, fixed = TRUE) else text
  lines  <- strsplit(text_n, "\n", fixed = TRUE)[[1]]

  # ── Walk lines, find raw exercise blocks ─────────────────────────────────
  i         <- 1L
  new_lines <- character(0)
  modified  <- FALSE

  while (i <= length(lines)) {
    line <- lines[i]

    is_raw_div      <- grepl('^<div id="ex-', line)
    already_wrapped <- i > 1L && grepl('^```\\{=html\\}', lines[i - 1L])

    if (is_raw_div && !already_wrapped) {

      # --- collect block through </script> ---
      div_id <- sub('^<div id="([^"]+)".*', "\\1", line)
      block  <- character(0)
      j      <- i
      while (j <= length(lines)) {
        block <- c(block, lines[j])
        if (grepl("^</script>", lines[j])) break
        j <- j + 1L
      }

      # --- extract "var ex = [...];" ---
      sc_start <- which(grepl("^<script>$",   block)) + 1L
      sc_end   <- which(grepl("^</script>$",  block)) - 1L
      sc_lines <- block[sc_start:sc_end]

      ex_start <- which(grepl("^var ex\\s*=\\s*\\[", sc_lines))
      ex_js    <- NULL
      if (length(ex_start)) {
        sl <- sc_lines[ex_start[1]]
        if (grepl("\\];\\s*$", sl)) {
          ex_js <- sl
        } else {
          for (k in seq(ex_start[1] + 1L, length(sc_lines))) {
            if (grepl("^\\];\\s*$", sc_lines[k])) {
              ex_js <- paste(sc_lines[ex_start[1]:k], collapse = "\n")
              break
            }
          }
        }
      }

      # --- parse with V8 ---
      ex_data <- NULL
      if (!is.null(ex_js)) {
        ctx <- v8()
        tryCatch({
          ctx$eval(ex_js)
          ex_data <- fromJSON(ctx$eval("JSON.stringify(ex)"),
                              simplifyVector = FALSE)
        }, error = function(e) message("  V8 error: ", e$message))
      }

      # --- build R chunk ---
      base_name  <- gsub("[^a-z0-9]", "_", tolower(sub("\\.Rmd$", "", fname)))
      id_clean   <- gsub("[^a-z0-9]", "_", div_id)
      chunk_name <- paste0(base_name, "_", id_clean, "_pdf")

      r_lines <- character(0)
      if (!is.null(ex_data) && length(ex_data)) {
        items_code <- vapply(ex_data, function(item) {
          q <- if (is.null(item$q) || is.na(item$q)) "" else item$q
          a <- if (is.null(item$a) || is.na(item$a)) "" else item$a
          paste0(
            "    list(\n",
            "      q = ", deparse(q), ",\n",
            "      a = ", deparse(a), "\n",
            "    )"
          )
        }, character(1))

        r_lines <- c(
          paste0("```{r ", chunk_name, ", echo=FALSE, results='asis'}"),
          "if (knitr::is_latex_output()) {",
          "  ex_items <- list(",
          paste(items_code, collapse = ",\n"),
          "  )",
          "  for (i in seq_along(ex_items)) {",
          "    cat(\"**\", i, \".** \", ex_items[[i]]$q, \"\\n\\n\", sep=\"\")",
          "    if (nchar(ex_items[[i]]$a) > 0)",
          "      cat(\"*Answer:* \", ex_items[[i]]$a, \"\\n\\n\", sep=\"\")",
          "  }",
          "}",
          "```",
          ""
        )
      }

      new_lines <- c(new_lines, r_lines, "```{=html}", block, "```", "")
      i        <- j + 1L
      modified <- TRUE

    } else {
      new_lines <- c(new_lines, line)
      i         <- i + 1L
    }
  }

  if (!modified) { message("No exercise blocks found: ", fname); return(invisible()) }

  # ── Write back as raw bytes ───────────────────────────────────────────────
  new_text <- paste(new_lines, collapse = "\n")
  if (crlf) new_text <- gsub("\n", "\r\n", new_text, fixed = TRUE)
  writeBin(charToRaw(enc2utf8(new_text)), fname)
  message("Written: ", fname)
}

setwd("C:/Users/hegel/Dropbox/_MINA TEXTER _db/Matematik för samhällsvetare/The Cheat Code - text/bookdown-project")
process_chapter("02-basics.Rmd")
