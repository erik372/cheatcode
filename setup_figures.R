# setup_figures.R
# Copy PDF figures from parent directory and convert to PNG for HTML output.
# Run from the bookdown-project directory before building the book.

library(pdftools)

parent_dir <- ".."  # The Cheat Code - text/
texten_dir <- "../../texten"  # sibling texten/ directory

# Create figures directory
if (!dir.exists("figures")) dir.create("figures")

# All figure PDFs needed for chapters 1-5
needed_figs <- c(
  "g_falsearrows.pdf",
  "g_numberline.pdf",
  "g_timeseriesindex.pdf",
  "plot_1a.pdf",
  "g_2functions.pdf",
  "g_pos_neg_slopes.pdf",
  "g_straight_line_example1.pdf",
  "g_straigthlines.pdf",
  "g_straight_exercise1.pdf",
  "g_nonlinear_ex.pdf",
  "g_discontinous.pdf",
  "ln_plots.pdf",
  "g_gdp_1800_2000.pdf",
  "g_gdphappy.pdf",
  "box1.pdf",
  "box2.pdf",
  "box3.pdf",
  # Chapters 6-14 (Part I remainder)
  "g_x2_plots.pdf",
  "g_x2_derivata.pdf",
  "g_andragradsekvationer.pdf",
  "gpoly.pdf",
  "g_p_polynom.pdf",
  "g_2lines.pdf",
  "g_fig63_4lines.pdf",
  "g_io_net.pdf",
  "g_social_nw.pdf",
  "g_vectors.pdf",
  "g_dejting.pdf",
  "g_nairu.pdf",
  "g_smoking.pdf",
  "g_intertemporal.pdf",
  "g_negative1.pdf",
  "g_nonlinear_1.pdf",
  "g_nonlin_first.pdf",
  "g_nonlin_2.pdf",
  "g_nonlinearsolutions.pdf",
  "g_twoequilibrias.pdf",
  "g_2equilibria.pdf",
  "g_derive_ax.pdf",
  "g_lim_logx.pdf",
  "g_oneoverx.pdf",
  "g_x3.pdf",
  "g_y4.pdf",
  "g_yequalx.pdf",
  "g_minx2.pdf",
  "g_minmax.pdf",
  "g_localminmax.pdf",
  "g_min_terrace.pdf",
  "g_min_ex2.pdf",
  "g_supplydemand.pdf",
  "g_laffer.pdf",
  "g_monopol.pdf",
  "g_monopsoni.pdf",
  "g_profit_revenue.pdf",
  "g_revcombos.pdf",
  "g_cakeutility.pdf",
  "g_utilitycombos.pdf",
  "g_utilitymaxbudget.pdf",
  "g_budget_utility.pdf",
  "g_cookies.pdf",
  "g_area_x2.pdf",
  "g_area2func.pdf",
  "g_integral_constant_C.pdf",
  "g_gini1.pdf",
  "g_ginitheory.pdf",
  "g_lorenz1.pdf"
)

for (fn in needed_figs) {
  # Try parent dir first, then texten/ as fallback
  src <- file.path(parent_dir, fn)
  if (!file.exists(src)) src <- file.path(texten_dir, fn)
  dst_pdf <- file.path("figures", fn)
  dst_png <- file.path("figures", sub("\\.pdf$", ".png", fn))

  if (!file.exists(src)) {
    message("Not found (skipping): ", src)
    next
  }

  # Copy PDF
  file.copy(src, dst_pdf, overwrite = TRUE)

  # Convert to PNG at 150 dpi
  tryCatch({
    pdf_convert(src, format = "png", dpi = 150, filenames = dst_png,
                pages = 1, verbose = FALSE)
    message("Converted: ", fn, " -> ", basename(dst_png))
  }, error = function(e) {
    message("Error converting ", fn, ": ", e$message)
  })
}

message("\nFigure setup complete. Check figures/ directory.")
