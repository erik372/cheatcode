library(pdftools)

src_dir  <- normalizePath("../", winslash = "/")
dest_dir <- normalizePath("figures/", winslash = "/")

message("Source dir: ", src_dir)
message("Dest dir:   ", dest_dir)

needed_png <- c(
  "fig 18.7 gdp deviations from trend.png",
  "g_188_gdp_happy.png",
  "g_194_life_earning_gender_ols.png",
  "g_3d_new2.png",
  "g_anscombe.png",
  "g_carpenter_dobkin.png",
  "g_did.png",
  "g_dispersion_1.png",
  "g_earnings_gender.png",
  "g_falseols.png",
  "g_frekvens_ex1.png",
  "g_gdp_lngdp_reg.png",
  "g_gdphappy_for_OLS.png",
  "g_gdplife_hist_box.png",
  "g_histogram_lifeexp_men_women.png",
  "g_iv.png",
  "g_kontrafaktisk.png",
  "g_life_inc_gender.png",
  "g_lifeexp_gdp_full.png",
  "g_ols.png",
  "g_ols183.png",
  "g_ols_ex2.png",
  "g_olspoints.png",
  "g_omitted.png",
  "g_rssesstss.png",
  "g_samvariation_ex1.png",
  "g_stapeldiagram_1.png",
  "g_two_histograms_example.png",
  "g_varians1.png",
  "g_weirdols_ex2.png"
)

for (png_name in needed_png) {
  dest_path <- file.path(dest_dir, png_name)
  if (file.exists(dest_path)) {
    message("Already exists: ", png_name)
    next
  }

  # Try PNG copy first
  src_png <- file.path(src_dir, png_name)
  if (file.exists(src_png)) {
    file.copy(src_png, dest_path)
    message("Copied PNG: ", png_name)
    next
  }

  # Try PDF conversion
  pdf_name <- sub("\\.png$", ".pdf", png_name)
  src_pdf  <- file.path(src_dir, pdf_name)
  if (!file.exists(src_pdf)) {
    message("WARNING - source not found: ", pdf_name)
    next
  }

  tryCatch({
    imgs <- pdf_render_page(src_pdf, page = 1, dpi = 150, numeric = FALSE)
    png::writePNG(imgs, dest_path)
    message("Converted: ", png_name)
  }, error = function(e) {
    message("ERROR converting ", pdf_name, ": ", conditionMessage(e))
  })
}

message("Done.")
