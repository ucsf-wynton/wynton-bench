#' Read bench log files
#'
#' @param file The bench log file.
#'
#' @param n_max Maximum number of lines to read.
#'
#' @return A tibble.
#'
#' @examples
#' file <- system.file("exdata", "ex-bench.log", package="wyntonbench")
#' data <- read_bench_log(file)
#' print(data)
#'
#' @importFrom readr read_tsv cols col_character col_double col_datetime col_integer
#' @export
read_bench_log <- function(file, n_max = +Inf) {
  col_types <- cols(
    .default    = col_double(),
    start        = col_datetime(format=""),
    id           = col_character(),
    hostname     = col_character(),
    ru_wallclock = col_double(),
    ru_stime     = col_double(),
    ru_utime     = col_double(),
    cpu_load     = col_character(), ## actually 'cpu_pct'
    ru_nvcsw     = col_integer(),
    ru_nivcsw    = col_integer(),
    ru_inblock   = col_integer(),
    ru_oublock   = col_integer(),
    ru_msgrcv    = col_integer(),
    ru_msgsnd    = col_integer(),
    ru_nsignals  = col_integer(),
    ru_maxrss    = col_integer(),
    ru_avgrss    = col_integer(),
    ru_nswap     = col_integer(),
    ru_majflt    = col_integer(),
    ru_minflt    = col_integer(),
    exit_status  = col_integer(),
    command      = col_character()
  )
  col_names <- setdiff(names(col_types$cols), ".default")
  data <- read_tsv(file, col_names=col_names, col_types=col_types, n_max=n_max)
  data$cpu_load <- as.numeric(sub("%", "", data$cpu_load)) / 100
  data
}
