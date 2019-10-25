#' Drop non-informative entries
#'
#' @export
trim_bench_log <- function(data) {
  stopifnot(is.data.frame(data), inherits(data, "bench_log"))
  data <- subset(data, !grepl("echo (HOSTNAME|PWD|TEST_DRIVE)=", command))
  data
}
