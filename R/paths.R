# Locate the repo root from wherever Databricks starts the R process,
# so helpers can be sourced with repo-relative paths.
repo_root <- function(marker = "R/fit_zip.R") {
  d <- normalizePath(getwd())
  for (i in 1:5) {
    if (file.exists(file.path(d, marker))) return(d)
    d <- dirname(d)
  }
  stop("Could not find repo root from ", getwd())
}
