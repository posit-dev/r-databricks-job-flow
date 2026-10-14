# One codebase: the modeling logic lives here and nowhere else.
# Data frame in -> data frame out, so it runs unchanged:
#   * locally on Workbench       (dplyr::group_modify / furrr)
#   * as a plain R Databricks job (parallel::mclapply on one big driver)
#   * on Spark workers           (sparklyr::spark_apply(group_by = ...))

fit_zip <- function(df) {
  t0 <- Sys.time()
  fit <- pscl::zeroinfl(
    events ~ age + comorbidity + los_days + medicare | comorbidity + los_days,
    data = df,
    dist = "poisson"
  )
  s <- summary(fit)$coefficients
  out <- rbind(
    data.frame(component = "count", term = rownames(s$count), s$count[, 1:2], row.names = NULL),
    data.frame(component = "zero",  term = rownames(s$zero),  s$zero[, 1:2],  row.names = NULL)
  )
  names(out)[3:4] <- c("estimate", "std_error")
  out <- cbind(facility_id = as.character(df$facility_id[1]), out)
  out$n_rows  <- nrow(df)
  out$host    <- Sys.info()[["nodename"]]
  out$seconds <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  out
}
