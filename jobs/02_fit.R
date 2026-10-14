# Databricks notebook source
# Step 2: fit one zero-inflated Poisson per site, in parallel on the driver.

# COMMAND ----------

dbutils.widgets.text("output_dir", "")
out_dir <- dbutils.widgets.get("output_dir")
source("../R/paths.R")
root <- repo_root()
source(file.path(root, "R/fit_zip.R"))

d <- read.csv(file.path(out_dir, "counts.csv"))
cores <- parallel::detectCores()
t0 <- Sys.time()
res <- do.call(rbind, parallel::mclapply(split(d, d$facility_id), fit_zip, mc.cores = cores))
elapsed <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1)

write.csv(res, file.path(out_dir, "fits.csv"), row.names = FALSE)
dbutils.notebook.exit(sprintf("%d fits on %d cores in %ss", length(unique(res$facility_id)), cores, elapsed))
