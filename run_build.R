source("lyx_to_rmd.R")
bookdown::render_book("index.Rmd", "bookdown::gitbook")
cat("Book built. Output in _book/\n")
