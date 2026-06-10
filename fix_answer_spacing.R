setwd("C:/Users/hegel/Dropbox/_MINA TEXTER _db/Matematik för samhällsvetare/The Cheat Code - text/bookdown-project")

exercise_files <- c(
  "02-basics.Rmd", "03-examples-applications.Rmd", "04-functions-graphs.Rmd",
  "05-logarithms.Rmd", "06-polynomial-equations.Rmd", "07-systems-linear-equations.Rmd",
  "08-theories-life-death-dating.Rmd", "09-nonlinear-equations-systems.Rmd",
  "10-derivative.Rmd", "11-optimization-functions.Rmd", "12-theories-cake-monopoly.Rmd",
  "13-integration.Rmd", "14-linear-algebra.Rmd", "15-counterfactual-analysis.Rmd",
  "16-variation-covariation.Rmd", "16-probability-discrete.Rmd",
  "17-probability-continuous.Rmd", "18-probability-normal-t.Rmd",
  "19-statistical-inference.Rmd", "20-causality-covariation.Rmd",
  "21-least-squares.Rmd", "22-covariation-social-science.Rmd",
  "23-least-squares-multiple-variables.Rmd", "24-regression-statistical-tests.Rmd",
  "25-regression-multiple-tests.Rmd", "26-ols-conditions.Rmd",
  "27-regression-causal-relationships.Rmd"
)

fix_spacing <- function(fname) {
  nbytes <- file.info(fname)$size
  raw    <- readBin(fname, "raw", n = nbytes)
  text   <- rawToChar(raw)
  Encoding(text) <- "UTF-8"
  crlf     <- grepl("\r\n", text, fixed = TRUE)
  text_n   <- if (crlf) gsub("\r\n", "\n", text, fixed = TRUE) else text
  new_text <- text_n
  for (letter in letters[1:15]) {
    old_pat  <- paste0("(", letter, ")\\\\(")   # matches literal (x)\\( in file
    new_pat  <- paste0("(", letter, ") \\\\(")  # replaces with    (x) \\( in file
    new_text <- gsub(old_pat, new_pat, new_text, fixed = TRUE)
  }
  if (identical(new_text, text_n)) { message("No changes: ", fname); return(invisible()) }
  if (crlf) new_text <- gsub("\n", "\r\n", new_text, fixed = TRUE)
  writeBin(charToRaw(enc2utf8(new_text)), fname)
  message("Fixed: ", fname)
}

for (f in exercise_files) fix_spacing(f)
