# R job flow on Databricks, submitted from R

A small multi-file R project that runs as a two-step Databricks Job, with the
code pulled straight from this Git repo. It's driven from any R session
(for example Posit Workbench) using [brickster](https://github.com/databrickslabs/brickster).

```
R/
  fit_zip.R     # model: zero-inflated Poisson per group (pscl), data frame in/out
  make_data.R   # synthetic zero-inflated count data
  paths.R       # find the repo root so helpers can be sourced by relative path
jobs/
  01_prep.R     # step 1 (R notebook): build data, write to a UC Volume
  02_fit.R      # step 2 (R notebook): fit per group with parallel::mclapply
  run_script.R  # shim notebook: runs any plain .R file in the repo with Rscript
scripts/
  hello.R       # plain .R file (no notebook header), used to test raw-script execution
run_flow.R      # creates the job with brickster and runs it
```

Notes
- Job entry points are R notebooks: `.R` files that start with `# Databricks notebook source`.
  A plain `.R` file can't be a task by itself; point `jobs/run_script.R` at it instead.
- R requires classic compute in **Dedicated** access mode.
- `parallel::mclapply` on the driver: set `OMP_NUM_THREADS=1` and `OPENBLAS_NUM_THREADS=1` (cluster env vars) to avoid BLAS thread oversubscription.
