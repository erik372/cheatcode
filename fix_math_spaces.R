files <- list.files(pattern = "\\.Rmd$")

for (f in files) {
  lines <- readLines(f, encoding = "UTF-8", warn = FALSE)
  changed <- FALSE
  new_lines <- character(length(lines))
  in_code_block <- FALSE
  in_display_math <- FALSE

  for (i in seq_along(lines)) {
    line <- lines[i]

    # Track code blocks (``` fences)
    if (grepl("^```", line)) {
      in_code_block <- !in_code_block
      new_lines[i] <- line
      next
    }
    if (in_code_block) {
      new_lines[i] <- line
      next
    }

    # Track display math ($$ blocks)
    n_double <- lengths(regmatches(line, gregexpr("\\$\\$", line)))
    if (n_double %% 2 != 0) {
      in_display_math <- !in_display_math
    }
    if (in_display_math || grepl("^\\$\\$", line)) {
      new_lines[i] <- line
      next
    }

    # Remove space immediately after opening $ (not $$)
    fixed <- gsub("(?<!\\$)\\$ ([^\\$ \\n])", "$\\1", line, perl = TRUE)
    # Remove space immediately before closing $ (not $$)
    fixed <- gsub("([^\\$ ]) \\$(?!\\$)", "\\1$", fixed, perl = TRUE)

    if (!identical(fixed, line)) changed <- TRUE
    new_lines[i] <- fixed
  }

  if (changed) {
    writeLines(new_lines, f, useBytes = FALSE)
    cat("Fixed:", f, "\n")
  }
}
cat("Done.\n")
