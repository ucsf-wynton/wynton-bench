#' Extract bench-log entries of a certain type
#'
#' @param logs A bench_log data.frame
#'
#' @param what Which type of entries to extract
#'
#' @param parse If TRUE, the `command` column of the extract entries
#' is parsed and the parsed values are appended as new columns.
#' This applies only to `uptime` and `total_time`.
#'
#' @return A [tibble::tibble] data.frame
#'
#' @example incl/extract_bench_log.R
#'
#' @export
extract_bench_log <- function(logs, what = c("uptime", "cp_file_source_to_ram", "cp_file_ram_to_drive", "cp_file_drive_to_ram", "rm_file_drive", "untar_ram_to_drive", "ls_recursive_drive", "find_drive", "du_drive", "chmod_recursive_drive", "tar_drive_to_ram", "tar_drive_to_drive", "gzip_drive_to_drive", "rm_folder_drive", "total_time"), parse = TRUE) {
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
  } else if (what == "cp_file_source_to_ram") {
    data <- subset(logs, grepl("cp .*/R-2[.]0[.]0[.]tar[.]gz /tmp", command))
  } else if (what == "cp_file_ram_to_drive") {
    data <- subset(logs, grepl("cp /tmp/.*/R-2[.]0[.]0[.]tar[.]gz [.]", command))
  } else if (what == "cp_file_drive_to_ram") {
    data <- subset(logs, grepl("cp R-2.0.0.tar.gz /tmp/", command, fixed=TRUE))
  } else if (what == "rm_file_drive") {
    data <- subset(logs, grepl("rm -- R-2.0.0.tar.gz", command, fixed=TRUE))
  } else if (what == "untar_ram_to_drive") {
    data <- subset(logs, grepl("tar zxf /tmp/.*/R-2[.]0[.]0[.]tar[.]gz -C .", command))
  } else if (what == "ls_recursive_drive") {
    data <- subset(logs, grepl("ls -lR -- R-2.0.0/", command, fixed=TRUE))
  } else if (what == "find_drive") {
    data <- subset(logs, grepl("find R-2.0.0/", command, fixed=TRUE))
  } else if (what == "du_drive") {
    data <- subset(logs, grepl("du -sb R-2.0.0/", command, fixed=TRUE))
  } else if (what == "chmod_recursive_drive") {
    data <- subset(logs, grepl("chmod -R o-r R-2.0.0/", command, fixed=TRUE))
  } else if (what == "tar_drive_to_ram") {
    data <- subset(logs, grepl("tar cf /tmp/", command, fixed=TRUE))
  } else if (what == "tar_drive_to_drive") {
    data <- subset(logs, grepl("tar cf foo.tar R-2.0.0", command, fixed=TRUE))
  } else if (what == "gzip_drive_to_drive") {
    data <- subset(logs, grepl("gzip foo.tar", command, fixed=TRUE))
  } else if (what == "rm_folder_drive") {
    data <- subset(logs, grepl("rm -rf R-2.0.0/", command, fixed=TRUE))
  } else if (what == "total_time") {
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
