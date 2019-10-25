#' Split up a bench log by entry type and saved to individual files
#'
#' @param logs A bench_log data.frame
#'
#' @param whats (character) Type of entries to extract
#'
#' @param prefix (character) The prefix to use for each file written
#'
#' @param parse If TRUE, the extracted entries are parsed by
#' [extract_bench_log].
#'
#' @param skip (logical) Should already existing output files be skipped,
#' or be recreated.
#' 
#' @param verbose (logical) Display verbose messages or not.
#'
#' @return A character vector of \file{*.bench_log.rds} files.
#'
#' 
#'
#' @importFrom utils file_test
split_bench_log <- function(logs, whats=eval(formals(extract_bench_log)$what), prefix=NULL, parse=TRUE, skip=TRUE, verbose=TRUE) {
  known_whats <- eval(formals(extract_bench_log)$what)
  whats <- match.arg(whats, choices=known_whats, several.ok=TRUE)

  pathnames <- sprintf("%s.bench_log.rds", whats)
  if (!is.null(prefix)) pathnames <- paste0(prefix, pathnames)
  names(pathnames) <- whats
  
  for (kk in seq_along(whats)) {
    what <- whats[kk]
    if (verbose) message("- What: ", sQuote(what))
    pathname <- pathnames[kk]
    if (skip && file_test("-f", pathname)) next
    data <- extract_bench_log(logs, what=what, parse=parse)
    stopifnot(is.data.frame(data), inherits(data, "bench_log"))
    saveRDS(data, file=pathname)
    data <- NULL
  }

  stopifnot(all(file_test("-f", pathnames)))
  pathnames
} ## split_bench_log()
