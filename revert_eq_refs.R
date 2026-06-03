files <- list.files(pattern = "\\.Rmd$")

for (f in files) {
  lines <- readLines(f, encoding = "UTF-8", warn = FALSE)
  in_code <- FALSE
  changed <- FALSE
  new_lines <- lines

  for (i in seq_along(lines)) {
    line <- lines[i]

    if (grepl("^```", line)) {
      in_code <- !in_code
      new_lines[i] <- line
      next
    }
    if (in_code) {
      new_lines[i] <- line
      next
    }

    # Remove manual parentheses: (\@ref(eq:label)) -> \@ref(eq:label)
    fixed <- gsub("\\(\\\\@ref\\(eq:([^)]+)\\)\\)",
                  "\\\\@ref(eq:\\1)",
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
