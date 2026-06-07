# restructure.R
# Splits ch15 and ch16 into new chapter files without modifying content.
# All section text is copied verbatim by line number.
# Only chapter-level headers and brief intro lines are new.

ch15 <- readLines("15-counterfactual-analysis.Rmd", encoding = "UTF-8")
ch16 <- readLines("16-variation-covariation.Rmd",   encoding = "UTF-8")

# ── helpers ──────────────────────────────────────────────────────────────────

# Return first line number containing fixed pattern
find_line <- function(lines, pattern) {
  idx <- which(grepl(pattern, lines, fixed = TRUE))
  if (length(idx) == 0L) stop(paste("Pattern not found:", pattern))
  idx[1L]
}

# Extract lines[from .. to-1], including any blank line immediately before 'from'
slice_section <- function(lines, from_pattern, to_pattern) {
  from <- find_line(lines, from_pattern)
  to   <- find_line(lines, to_pattern) - 1L
  # Include preceding blank line so sections are separated nicely
  if (from > 1L && lines[from - 1L] == "") from <- from - 1L
  if (to < from) return(character(0L))
  lines[from:to]
}

# Extract from pattern to end-of-file
slice_to_end <- function(lines, from_pattern) {
  from <- find_line(lines, from_pattern)
  if (from > 1L && lines[from - 1L] == "") from <- from - 1L
  lines[from:length(lines)]
}

# ── standard setup chunk ─────────────────────────────────────────────────────
setup <- c(
  '```{r setup, include=FALSE}',
  'knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE, fig.align = "left")',
  '```'
)

# ════════════════════════════════════════════════════════════════════════════
# FILE A: 15a-data-descriptive-stats.Rmd
# Sections from ch15: Population/Sample, Variables, Data types,
#                     Sampling, Uncertainty
# Sections from ch16: Frequency distribution, Central tendency,
#                     Variance/SD, Standardized values
#   (EXCLUDING the transition paragraph "So far in this chapter...")
# ════════════════════════════════════════════════════════════════════════════

# ── from ch15 ────────────────────────────────────────────────────────────────
a_population  <- slice_section(ch15, "#sec-population-urval-superpopulation}",
                                      "#sec-information-och-variabler}")
a_variables   <- slice_section(ch15, "#sec-information-och-variabler}",
                                      "#sec-olika-typer-av-data}")
a_datatypes   <- slice_section(ch15, "#sec-olika-typer-av-data}",
                                      "#sec-samla-in-data}")
a_sampling    <- slice_section(ch15, "#sec-samla-in-data}",
                                      "#sec-ar-allting-osakert}")
a_uncertainty <- slice_section(ch15, "#sec-ar-allting-osakert}",
                                      "## Exercises")

# ── from ch16 ────────────────────────────────────────────────────────────────
a_freq        <- slice_section(ch16, "#sec-frekvensfordelning}",
                                      "#sec-spridningsmatt-kvartiler-och}")
a_central     <- slice_section(ch16, "#sec-spridningsmatt-kvartiler-och}",
                                      "#sec-varians-och-standardavvikelse}")
a_variance    <- slice_section(ch16, "#sec-varians-och-standardavvikelse}",
                                      "#sec-standardiserade-varden}")

# Standardized values: extract then trim off the transition paragraph
a_std_raw     <- slice_section(ch16, "#sec-standardiserade-varden}",
                                      "#sec-samvariation-i-diagram}")
transition_ln <- which(grepl("So far in this chapter", a_std_raw, fixed = TRUE))[1L]
if (!is.na(transition_ln)) {
  cut <- transition_ln - 1L
  while (cut > 1L && a_std_raw[cut] == "") cut <- cut - 1L
  a_std <- a_std_raw[1L:cut]
} else {
  a_std <- a_std_raw  # fallback: keep as-is
}

# ── assemble file A ──────────────────────────────────────────────────────────
header_a <- c(
  "# Data and Descriptive Statistics {#chap-data-descriptive-stats}",
  "",
  "This chapter introduces fundamental concepts for analytical work: how we",
  "collect and organise data, how populations and samples relate to each other,",
  "and how to describe variation in data using basic statistical measures.",
  ""
)

file_a <- c(
  setup, "",
  header_a,
  a_population,
  a_variables,
  a_datatypes,
  a_sampling,
  a_freq,
  a_central,
  a_variance,
  a_std,
  "",
  a_uncertainty
)

writeLines(file_a, "15a-data-descriptive-stats.Rmd", useBytes = FALSE)
cat("Written: 15a-data-descriptive-stats.Rmd (", length(file_a), "lines)\n")

# ════════════════════════════════════════════════════════════════════════════
# FILE B: 15b-causality-covariation.Rmd
# Sections from ch15: Cause/effect, Covariation-as-condition, Experiments
# Sections from ch16: Covariation in graphs, Covariance, Correlation,
#                     Chapter summary, Exercises (both ch15 and ch16)
# Keeps anchor {#chap-kontrafaktisk-analys} for backward compatibility
# ════════════════════════════════════════════════════════════════════════════

# ── from ch15 ────────────────────────────────────────────────────────────────
b_cause   <- slice_section(ch15, "#sec-orsak-och-effekt}",
                                   "#sec-samvariation}")
b_cov_cond <- slice_section(ch15, "#sec-samvariation}",
                                   "#sec-observationsstudie-experiment}")
b_exper   <- slice_section(ch15, "#sec-observationsstudie-experiment}",
                                   "#sec-population-urval-superpopulation}")

# ── from ch16 ────────────────────────────────────────────────────────────────
b_cov_graph <- slice_section(ch16, "#sec-samvariation-i-diagram}",
                                     "#sec-kovarians}")
b_covar     <- slice_section(ch16, "#sec-kovarians}",
                                     "#sec-pearsons-r}")
b_corr      <- slice_section(ch16, "#sec-pearsons-r}",
                                     "## Chapter summary")
b_summary   <- slice_section(ch16, "## Chapter summary",
                                     "## Exercises")

# ── exercises ────────────────────────────────────────────────────────────────
b_ex15 <- slice_to_end(ch15, "## Exercises")  # causality exercises
# ch16 exercises: skip the "## Exercises" heading to avoid duplicate heading
ex16_from <- find_line(ch16, "## Exercises")
b_ex16 <- ch16[(ex16_from + 1L):length(ch16)]  # skip heading line, keep rest

# ── assemble file B ──────────────────────────────────────────────────────────
header_b <- c(
  "# Causality and Covariation {#chap-kontrafaktisk-analys}",
  "",
  "This chapter introduces the logic of causal analysis: how we reason about",
  "causes and effects, what role covariation plays as a necessary condition",
  "for causality, and how to measure covariation mathematically.",
  ""
)

file_b <- c(
  setup, "",
  header_b,
  b_cause,
  b_cov_cond,
  b_exper,
  "",
  "## Covariation: Mathematical Measures {#sec-measuring-covariation}",
  "",
  "Having established that covariation is a necessary condition for causality,",
  "we now introduce mathematical tools for measuring it.",
  "",
  b_cov_graph,
  b_covar,
  b_corr,
  b_summary,
  b_ex15,
  b_ex16
)

writeLines(file_b, "15b-causality-covariation.Rmd", useBytes = FALSE)
cat("Written: 15b-causality-covariation.Rmd (", length(file_b), "lines)\n")

cat("\nDone. Verify the new files before updating _bookdown.yml.\n")
