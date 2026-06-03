files <- list.files(pattern = "\\.Rmd$")

for (f in files) {
  lines <- readLines(f, encoding = "UTF-8", warn = FALSE)
  in_code <- FALSE
  changed <- FALSE
  new_lines <- lines

  for (i in seq_along(lines)) {
    line <- lines[i]

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

    # Wrap \@ref(eq:label) in parentheses, only if not already preceded by (
    # The (?<!\() lookbehind ensures we don't double-wrap
    fixed <- gsub("(?<!\\()\\\\@ref\\(eq:([^)]+)\\)",
                  "(\\\\@ref(eq:\\1))",
                  line, perl = TRUE)

    if (!identical(fixed, line)) changed <- TRUE
    new_lines[i] <- fixed
  }

  if (changed) {
    writeLines(new_lines, f, useBytes = FALSE)
    cat("Fixed:", f, "\n")
  }
}
cat("Done.\n")
