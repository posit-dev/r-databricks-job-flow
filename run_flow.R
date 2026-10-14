# Create and run a two-step, Git-sourced Databricks Job from R with brickster.
# Auth: DATABRICKS_HOST / DATABRICKS_TOKEN in the environment.
library(brickster)

repo       <- "https://github.com/posit-dev/r-databricks-job-flow"
branch     <- "main"
output_dir <- "/Volumes/jb-demos/r_flow_demo/files"   # any UC Volume you can write to

# One shared single-node cluster for every step in the run
nc <- new_cluster(
  num_workers    = 0,
  spark_version  = "17.3.x-scala2.13",
  node_type_id   = "Standard_D4ds_v4",          # 4 cores / 16 GB
  spark_conf     = list("spark.master" = "local[*]",
                        "spark.databricks.cluster.profile" = "singleNode"),
  spark_env_vars = list(OPENBLAS_NUM_THREADS = "1"),
  cloud_attrs    = azure_attributes(availability = "ON_DEMAND"),
  custom_tags    = list(ResourceClass = "SingleNode", project = "r-flow-demo")
)
# brickster 0.2.15 drops data_security_mode from new_cluster(); set it directly.
# R needs Dedicated access mode.
nc$data_security_mode <- "SINGLE_USER"
nc$single_user_name   <- db_current_user()$userName

params <- list(output_dir = output_dir)
pkgs   <- libraries(lib_cran("pscl"))

job <- db_jobs_create(
  name         = "r-job-flow-demo",
  git_source   = git_source(repo, git_provider = "github", reference = branch),
  job_clusters = list(shared = nc),            # name = job_cluster_key
  tasks = job_tasks(
    job_task(
      task_key        = "prep",
      job_cluster_key = "shared",
      task            = notebook_task("jobs/01_prep", base_parameters = params)
    ),
    job_task(
      task_key        = "fit",
      depends_on      = "prep",
      job_cluster_key = "shared",
      task            = notebook_task("jobs/02_fit", base_parameters = params),
      libraries       = pkgs
    )
  )
)

run <- db_jobs_run_now(job_id = job$job_id)
cat("job_id:", format(job$job_id, scientific = FALSE),
    " run_id:", format(run$run_id, scientific = FALSE), "\n")
