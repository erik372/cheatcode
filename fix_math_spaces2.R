fix_math_line <- function(line) {
  chars <- strsplit(line, "")[[1]]
  n <- length(chars)
  if (n == 0) return(line)

  out <- vector("character", n + 200)
  op <- 0
  in_math <- FALSE
  i <- 1

  while (i <= n) {
    ch <- chars[i]

    # Escaped dollar: pass through unchanged
    if (ch == "\\" && i < n && chars[i + 1] == "$") {
      op <- op + 1; out[op] <- "\\"
      op <- op + 1; out[op] <- "$"
      i <- i + 2
      next
    }

    if (ch == "$") {
      # Display math $$: pass through unchanged
      if (i < n && chars[i + 1] == "$") {
        op <- op + 1; out[op] <- "$"
        op <- op + 1; out[op] <- "$"
        i <- i + 2
        next
      }

      if (!in_math) {
        # Opening $: ensure space before it when needed
        if (op > 0) {
          last <- out[op]
          needs_space <- last != " " && last != "\t" &&
            last != "(" && last != "[" && last != "{" &&
            last != "\n" && last != "-"
          if (needs_space) {
            op <- op + 1; out[op] <- " "
          }
        }
        op <- op + 1; out[op] <- "$"
        in_math <- TRUE
        # Skip spaces immediately after opening $
        while (i < n && chars[i + 1] == " ") i <- i + 1

      } else {
        # Closing $: remove trailing spaces inside math
        while (op > 0 && out[op] == " ") op <- op - 1
        op <- op + 1; out[op] <- "$"
        in_math <- FALSE
        # Ensure space after closing $ when followed by alphanumeric
        if (i < n && grepl("[a-zA-Z0-9]", chars[i + 1])) {
          op <- op + 1; out[op] <- " "
        }
      }
      i <- i + 1
      next
    }

    op <- op + 1; out[op] <- ch
    i <- i + 1
  }

  paste(out[1:op], collapse = "")
}

files <- list.files(pattern = "\\.Rmd$")

for (f in files) {
  lines <- readLines(f, encoding = "UTF-8", warn = FALSE)
  in_code <- FALSE
  in_yaml <- grepl("^---", lines[1])
  yaml_done <- FALSE
  changed <- FALSE
  new_lines <- lines

  for (i in seq_along(lines)) {
    line <- lines[i]

    # Skip YAML front matter
    if (in_yaml && !yaml_done) {
      if (i > 1 && grepl("^---", line)) yaml_done <- TRUE
      new_lines[i] <- line
      next
    }

    # Track code fences
    if (grepl("^```", line)) {
      in_code <- !in_code
      new_lines[i] <- line
      next
    }
    if (in_code) {
      new_lines[i] <- line
      next
    }

    fixed <- fix_math_line(line)
    if (!identical(fixed, line)) changed <- TRUE
    new_lines[i] <- fixed
  }

  if (changed) {
    writeLines(new_lines, f, useBytes = FALSE)
    cat("Fixed:", f, "\n")
  }
}
cat("Done.\n")
