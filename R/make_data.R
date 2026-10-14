# Synthetic zero-inflated count data, one segment per site.
make_counts <- function(n_sites = 24, rows_per = 20000, seed = 2026) {
  set.seed(seed)
  do.call(rbind, lapply(seq_len(n_sites), function(f) {
    n <- rows_per
    age         <- round(runif(n, 18, 90))
    comorbidity <- rpois(n, 2)
    los_days    <- rpois(n, 4) + 1
    medicare    <- rbinom(n, 1, 0.4)
    b0 <- rnorm(1, -2.0, 0.2)
    p_zero <- plogis(0.5 - 0.3 * comorbidity - 0.1 * los_days)
    lambda <- exp(b0 + 0.01 * age + 0.25 * comorbidity + 0.08 * los_days + 0.2 * medicare)
    events <- ifelse(runif(n) < p_zero, 0L, rpois(n, lambda))
    data.frame(facility_id = sprintf("F%02d", f), age, comorbidity, los_days, medicare, events)
  }))
}
