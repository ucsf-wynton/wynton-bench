#' Drop non-informative entries
#'
#' @param data A bench_log data.frame
#'
#' @return A [tibble::tibble] data.frame of class `bench_log`.
#'
#' @export
trim_bench_log <- function(data) {
  # To please R CMD check
  command <- NULL
  
  stopifnot(is.data.frame(data), inherits(data, "bench_log"))
  data <- subset(data, !grepl("echo (HOSTNAME|PWD|TEST_DRIVE)=", command))
  data
}
