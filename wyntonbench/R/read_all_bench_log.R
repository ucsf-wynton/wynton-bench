#' Read multiple bench log files at once
#'
#' @param path The path to bench log files.
#'
#' @param recursive If TRUE, bench log files are searched recursively.
#'
#' @param pattern A regular expression matching files to be read.
#'
#' @param \dots Addition arguments passed to [read_bench_log].
#'
#' @return A tibble.
#'
#' @examples
#' path <- system.file("exdata", package="wyntonbench")
#' data <- read_all_bench_logs(path)
#' print(data)
#'
#' @export
read_all_bench_logs <- function(path, recursive=TRUE, pattern="[.]log$", ...) {
  files <- dir(path=path, pattern=pattern, recursive=recursive, full.names=TRUE)
  logs <- lapply(files, FUN = read_bench_log, ...)
  do.call(rbind, logs)
}
