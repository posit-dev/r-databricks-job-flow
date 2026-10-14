# A plain R script with NO Databricks notebook header.
cat("R:", R.version.string, "\n")
cat("wd:", getwd(), "\n")
args <- commandArgs(trailingOnly = TRUE)
cat("args:", paste(args, collapse = " "), "\n")
