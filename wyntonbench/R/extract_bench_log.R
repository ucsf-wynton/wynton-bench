#' Extract bench-log entries of a certain type
#'
#' @param logs A bench_log data.frame
#'
#' @param what Which type of entries to extract
#'
#' @param parse If TRUE, the `command` column of the extract entries
#' is parsed and the parsed valus are appended as new columns.
#' This applies only to `uptime` and `total-time`.
#'
#' @return A [tibble::tibble] data.frame
#'
#' @export
extract_bench_log <- function(logs, what = c("uptime", "cp-file-source-to-ram", "cp-file-ram-to-drive", "cp-file-drive-to-ram", "rm-file-drive", "untar-ram-to-drive", "ls-recursive-drive", "find-drive", "du-drive", "chmod-recursive--drive", "tar-drive-to-ram", "tar-drive-to-drive", "gzip-drive-to-drive", "rm-folder-drive", "total-time"), parse = TRUE) {
  ## To please R CMD check
  command <- NULL
  
  stopifnot(is.data.frame(logs), inherits(logs, "bench_log"))
  what <- match.arg(what)
  if (what == "uptime") {
    data <- subset(logs, grepl("echo uptime=", command))
    if (parse) {
      value <- strsplit(data$command, split=",", fixed=TRUE)
      value <- lapply(value, FUN=function(x) {
        n <- length(x)
        x <- x[(n-3):n]
	x <- gsub("( |users|load average:)", "", x)
	as.numeric(x)
      })
      ns <- unique(lengths(value))
      stopifnot(length(ns) == 1L, ns == 4L)
      value <- matrix(unlist(value, use.names=FALSE), ncol=4L, byrow=TRUE)
      data$users <- as.integer(value[,1,drop=TRUE])
      data$load_1min <- value[,2,drop=TRUE]
      data$load_5min <- value[,3,drop=TRUE]
      data$load_15min <- value[,4,drop=TRUE]
    }
  } else if (what == "cp-file-source-to-ram") {
    data <- subset(logs, grepl("cp .*/R-2[.]0[.]0[.]tar[.]gz /tmp", command))
  } else if (what == "cp-file-ram-to-drive") {
    data <- subset(logs, grepl("cp /tmp/.*/R-2[.]0[.]0[.]tar[.]gz [.]", command))
  } else if (what == "cp-file-drive-to-ram") {
    data <- subset(logs, grepl("cp R-2.0.0.tar.gz /tmp/", command, fixed=TRUE))
  } else if (what == "rm-file-drive") {
    data <- subset(logs, grepl("rm -- R-2.0.0.tar.gz", command, fixed=TRUE))
  } else if (what == "untar-ram-to-drive") {
    data <- subset(logs, grepl("tar zxf /tmp/.*/R-2[.]0[.]0[.]tar[.]gz -C .", command))
  } else if (what == "ls-recursive-drive") {
    data <- subset(logs, grepl("ls -lR -- R-2.0.0/", command, fixed=TRUE))
  } else if (what == "find-drive") {
    data <- subset(logs, grepl("find R-2.0.0/", command, fixed=TRUE))
  } else if (what == "du-drive") {
    data <- subset(logs, grepl("du -sb R-2.0.0/", command, fixed=TRUE))
  } else if (what == "chmod-recursive--drive") {
    data <- subset(logs, grepl("chmod -R o-r R-2.0.0/", command, fixed=TRUE))
  } else if (what == "tar-drive-to-ram") {
    data <- subset(logs, grepl("tar cf /tmp/", command, fixed=TRUE))
  } else if (what == "tar-drive-to-drive") {
    data <- subset(logs, grepl("tar cf foo.tar R-2.0.0", command, fixed=TRUE))
  } else if (what == "gzip-drive-to-drive") {
    data <- subset(logs, grepl("gzip foo.tar", command, fixed=TRUE))
  } else if (what == "rm-folder-drive") {
    data <- subset(logs, grepl("rm -rf R-2.0.0/", command, fixed=TRUE))
  } else if (what == "total-time") {
    data <- subset(logs, grepl("echo total_time=", command))
    if (parse) {
      value <- sub("echo total_time=", "", data$command)
      units <- sub(".* ", "", value)
      stopifnot(all(units %in% c("seconds")))
      value <- as.numeric(sub(" .*", "", value))
      data$total_time <- .difftime(value, units="secs")
    }
  }
  
  if (nrow(data) == 0L) {
    warning("No matching entries: ", sQuote(what))
  }
  
  data
}
