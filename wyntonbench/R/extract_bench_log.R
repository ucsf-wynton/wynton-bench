#' Extract bench-log entries of a certain type
#'
#' @param logs A bench_log data.frame
#'
#' @param what Which type of benchmark to extract (see below).
#'
#' @param parse If TRUE, the `command` column of the extract entries
#' is parsed and the parsed values are appended as new columns.
#' This applies only to `uptime` and `total_time`.
#'
#' @return A [tibble::tibble] data.frame with columns:
#'
#'  * `timestamp`   (POSIXct): The time when the command was called
#'  * `id`        (character): A unique identify for this command call
#'  * `hostname`  (character): The hostname where this command was called
#'  * `drive`     (character): The mount point on which the test was performed
#'  * `ru_wallclock` (double): 
#'  * `ru_stime`     (double): 
#'  * `ru_utime`     (double): 
#'  * `cpu_pct`      (double): 
#'  * `ru_nvcsw`     (double): 
#'  * `ru_invcsw`    (double): 
#'  * `ru_inblock`   (double): 
#'  * `ru_outblock`  (double): 
#'  * `ru_maxrss`    (double): 
#'  * `ru_minflt`    (double): 
#'  * `exit_status`  (double): The exit code of the command called
#'  * `command`   (character): The verbatim command called by this test
#'
#' @section Available benchmarks and their corresponding commands:
#'
#' |    | Benchmark               | Command                                                   |
#' |---:|:------------------------|:----------------------------------------------------------|
#' |  1 | `uptime`                | `uptime`                                                  |
#' |  2 | `cp_file_source_to_ram` | `cp $BENCH_SOURCE/R-2.0.0.tar.gz /tmp/`                   |
#' |  3 | `cp_file_ram_to_drive`  | `cp /tmp/R-2.0.0.tar.gz $BENCH_DRIVE/`                    |
#' |  4 | `cp_file_drive_to_ram`  | `cp $BENCH_DRIVE/R-2.0.0.tar.gz /tmp/`                    |
#' |  5 | `rm_file_drive`         | `rm $BENCH_DRIVE/R-2.0.0.tar.gz`                          |
#' |  6 | `untar_ram_to_drive`    | `tar zxf /tmp/R-2.0.0.tar.gz -C $BENCH_DRIVE/`            |
#' |  7 | `ls_recursive_drive`    | `ls -lR $BENCH_DRIVE/R-2.0.0/src/library/`                |
#' |  8 | `find_drive`            | `find $BENCH_DRIVE/R-2.0.0/ -type f -name Rconnections.h` |
#' |  9 | `du_drive`              | `du -sb $BENCH_DRIVE/R-2.0.0/`                            |
#' | 10 | `chmod_recursive_drive` | `chmod -R o-r $BENCH_DRIVE/R-2.0.0/`                      |
#' | 11 | `tar_drive_to_ram`      | `tar cf /tmp/foo.tar $BENCH_DRIVE/R-2.0.0/`               |
#' | 12 | `tar_drive_to_drive`    | `tar cf $BENCH_DRIVE/foo.tar $BENCH_DRIVE/R-2.0.0/`       |
#' | 13 | `gzip_drive_to_drive`   | `gzip $BENCH_DRIVE/foo.tar`                               |
#' | 14 | `rm_folder_drive`       | `rm -rf $BENCH_DRIVE/R-2.0.0/`                            |
#' | 15 | `total_time`            | Total time for all of the above steps                     |
#'
#'
#' @section How the raw data is produced:
#' These data are produced using the \file{utils/bench.sh} script that
#' benchmarks the called command using something like:
#'
#' ```sh
#' $(type -P time) --format="%e\t%S\t%U\t%P\t%w\t%c\t%I\t%O\t%r\t%s\t%k\t%M\t%t\t%W\t%F\t%R\t%x\t%C" <command>
#' ```
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
