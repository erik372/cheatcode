lyx_path <- "Hegelund - The Cheat Code - 260527.lyx"
lines <- readLines(lyx_path, encoding = "UTF-8", warn = FALSE)

chapter_lines <- which(grepl("^\\\\begin_layout Chapter$",  lines))
chapter_star  <- which(grepl("^\\\\begin_layout Chapter\\*$", lines))
ch_start <- chapter_star[1]
ch_end   <- chapter_lines[6] - 1

ch_boundaries <- c(chapter_star[1], chapter_lines[1:5], chapter_lines[6])
ch_names <- c("Preface", "Ch1: Why math?", "Ch2: Basics",
               "Ch3: Examples", "Ch4: Functions & graphs", "Ch5: Logarithms")

sec_lines_idx <- which(grepl("^\\\\begin_layout (Chapter|Chapter\\*|Section|Section\\*)", lines))

get_location <- function(line_no) {
  secs_before <- sec_lines_idx[sec_lines_idx < line_no]
  if (length(secs_before) == 0) return("(before chapters)")
  last_sec <- tail(secs_before, 1)
  j <- last_sec + 1
  while (j <= length(lines) && nchar(trimws(lines[j])) == 0) j <- j + 1
  ch_idx   <- max(which(ch_boundaries <= line_no))
  ch_name  <- if (ch_idx <= length(ch_names)) ch_names[ch_idx] else "Ch5"
  sec_text <- trimws(lines[j])
  if (nchar(sec_text) > 45) sec_text <- paste0(substr(sec_text, 1, 43), "...")
  paste0(ch_name, " / ", sec_text)
}

cite_starts <- which(grepl("^\\\\begin_inset CommandInset citation", lines))
cite_starts  <- cite_starts[cite_starts >= ch_start & cite_starts <= ch_end]

results <- data.frame(key = character(), location = character(),
                      stringsAsFactors = FALSE)
for (i in cite_starts) {
  key_line <- grep('^key "', lines[(i + 1):(i + 10)], value = TRUE)
  if (length(key_line) == 0) next
  keys <- gsub('^key "(.*)"$', "\\1", key_line[1])
  keys <- trimws(strsplit(keys, ",")[[1]])
  loc  <- get_location(i)
  for (k in keys) {
    results <- rbind(results, data.frame(key = k, location = loc,
                                         stringsAsFactors = FALSE))
  }
}

# Aggregate: unique locations per key, count occurrences
agg <- do.call(rbind, lapply(unique(results$key), function(k) {
  rows <- results[results$key == k, ]
  locs <- unique(rows$location)
  loc_str <- if (length(locs) <= 3) paste(locs, collapse = "; ")
             else paste0(paste(locs[1:3], collapse = "; "), " (+ ", length(locs)-3, " more)")
  data.frame(key = k, count = nrow(rows), locations = loc_str,
             stringsAsFactors = FALSE)
}))
agg <- agg[order(-agg$count), ]

write.csv(agg, "refs_raw.csv", row.names = FALSE)
message("Done. Unique citation keys: ", nrow(agg))
print(agg, row.names = FALSE)
