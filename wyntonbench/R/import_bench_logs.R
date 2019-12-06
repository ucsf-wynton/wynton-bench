#' Import raw bench log files and save per hostname
#'
#' @param root (character) A folder to be imported.
#'
#' @param skip (logical) Should already existing output files be skipped,
#' or be recreated.
#' 
#' @param verbose (logical) Display verbose messages or not.
#'
#' @return A character vector of \file{*.bench_log.rds} files.
#'
#' @importFrom utils file_test
import_bench_logs <- function(root="wynton-bench-logs", skip=TRUE, verbose=FALSE) {
  pathnames <- dir(path=root, pattern="bench-files-.*[.]log$", recursive=TRUE)
  hostnames <- unique(dirname(pathnames))
  if (verbose) message(sprintf("Hostnames: [n=%d]", length(hostnames)))

  for (kk in seq_along(hostnames)) {
    hostname <- hostnames[kk]
    if (verbose) message(sprintf("- Hostname %d ('%s') of %d", kk, hostname, length(hostnames)))
    path <- file.path(root, hostname)
    pathname <- file.path(root, sprintf("%s.bench_log.rds", hostname))
    if (skip && file_test("-f", pathname)) next
    pathnames <- dir(path=path, pattern="bench-files-.*[.]log$", full.names=TRUE)
    data <- lapply(pathnames, FUN=read_bench_log)
    data <- do.call(rbind, data)
    stopifnot(is.data.frame(data), inherits(data, "bench_log"))
    saveRDS(data, file=pathname)
  }

  dir(path=root, pattern="[.]bench_log[.]rds$", full.names=TRUE)
} ## import_bench_logs()
