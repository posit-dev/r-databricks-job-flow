# Databricks notebook source
# Shim: run an unmodified .R script from this repo with Rscript on the driver.
# Jobs can't use a plain .R file as a task, so this notebook is the entry point.

# COMMAND ----------

dbutils.widgets.text("script", "scripts/hello.R")
dbutils.widgets.text("args", "")
source("../R/paths.R")
script <- file.path(repo_root(), dbutils.widgets.get("script"))
args   <- strsplit(dbutils.widgets.get("args"), " ", fixed = TRUE)[[1]]

out <- system2("Rscript", c(shQuote(script), args), stdout = TRUE, stderr = TRUE)
cat(out, sep = "\n")
status <- attr(out, "status")
if (!is.null(status) && status != 0) stop("Rscript exited with status ", status)
dbutils.notebook.exit(paste(out, collapse = " | "))
