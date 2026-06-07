# verify_restructure.R
# Checks that every content line from ch15 and ch16 ended up in either
# 15a or 15b (or is legitimately excluded: setup chunks, chapter headers,
# chapter-level intro paragraphs, the transition paragraph).

ch15  <- readLines("15-counterfactual-analysis.Rmd",  encoding = "UTF-8")
ch16  <- readLines("16-variation-covariation.Rmd",    encoding = "UTF-8")
a_new <- readLines("15a-data-descriptive-stats.Rmd",  encoding = "UTF-8")
b_new <- readLines("15b-causality-covariation.Rmd",   encoding = "UTF-8")

# Lines present in either new file (trim whitespace for comparison)
in_new <- trimws(c(a_new, b_new))

check_source <- function(src_lines, src_name) {
  missing <- character(0)
  for (i in seq_along(src_lines)) {
    line <- trimws(src_lines[i])

    # Skip blank lines – they're structural and may not be preserved exactly
    if (nchar(line) == 0) next

    # Skip the r-setup chunk lines (legitimately not copied)
    if (grepl("^```\\{r setup", line)) next
    if (grepl("knitr::opts_chunk\\$set", line)) next
    if (line == "```") next

    # Skip original chapter-level heading lines (replaced by new headings)
    if (grepl("^# Fundamental Counterfactual Analysis", line)) next
    if (grepl("^# Variation and covariation", line)) next

    # Skip the chapter-level intro paragraphs (first paragraph after heading,
    # before first ##-section). These are the only lines that sit between the
    # chapter # heading and the first ## heading and are not part of any
    # named section.
    if (src_name == "ch15" && i == 9)  next   # "This chapter introduces..."
    if (src_name == "ch16" && i %in% c(8, 9)) next  # "In the previous chapter..."

    # Skip the transition paragraph (deliberately excluded)
    if (grepl("So far in this chapter we have described", line)) next

    # Check if this line appears in either new file
    if (!(line %in% in_new)) {
      missing <- c(missing, sprintf("  Line %3d: %s", i, src_lines[i]))
    }
  }
  missing
}

cat("=== Checking ch15 ===\n")
m15 <- check_source(ch15, "ch15")
if (length(m15) == 0) {
  cat("OK – all content lines accounted for.\n")
} else {
  cat(sprintf("MISSING (%d lines):\n", length(m15)))
  cat(paste(m15, collapse = "\n"), "\n")
}

cat("\n=== Checking ch16 ===\n")
m16 <- check_source(ch16, "ch16")
if (length(m16) == 0) {
  cat("OK – all content lines accounted for.\n")
} else {
  cat(sprintf("MISSING (%d lines):\n", length(m16)))
  cat(paste(m16, collapse = "\n"), "\n")
}
