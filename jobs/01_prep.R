# Databricks notebook source
# Step 1: build the modeling dataset and write it to a Unity Catalog Volume.

# COMMAND ----------

dbutils.widgets.text("output_dir", "")
out_dir <- dbutils.widgets.get("output_dir")
cat("getwd():", getwd(), "\n")
cat("relative '../R/make_data.R' exists:", file.exists("../R/make_data.R"), "\n")

source("../R/paths.R")                       # repo-relative source
root <- repo_root()
cat("repo root:", root, "\n")
source(file.path(root, "R/make_data.R"))

d <- make_counts()
write.csv(d, file.path(out_dir, "counts.csv"), row.names = FALSE)
dbutils.notebook.exit(sprintf("wrote %d rows from %s", nrow(d), root))
