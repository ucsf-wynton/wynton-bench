#' Reads a bench log file
#'
#' @param pathname The pathname of the bench log file to read.
#'
#' @param \ldots Additional arguments passed to [readr::read_tsv].
#'
#' @return A [tibble::tibble] data.frame.
#'
#' @importFrom readr read_tsv cols col_double col_datetime col_character
#" @importFrom tibble as_tibble
read_bench_log <- function(pathname, ...) {
  library(readr)
  col_types <- cols(
    .default  = col_double(),
    timestamp = col_datetime(format = ""),
    id        = col_character(),
    hostname  = col_character(),
    cpu_pct   = col_character(),
    command   = col_character()
  )
  
  col_names <- c("timestamp", "id", "hostname", "ru_wallclock", "ru_stime", "ru_utime", "cpu_pct", "ru_nvcsw", "ru_invcsw", "ru_inblock", "ru_outblock", "ru_msgrcv", "ru_msgsnd", "ru_nsignals", "ru_maxrss", "ru_avgrss", "ru_nswap", "ru_majflt", "ru_minflt", "exit_status", "command")

  data <- readr::read_tsv(pathname, col_types=col_types, col_names=col_names, ...)
  colnames(data) <- col_names

  ## Drop non-informative columns which are always reported with zeros
  drop <- c("ru_msgrcv", "ru_msgsnd", "ru_nsignals", "ru_avgrss", "ru_nswap", "ru_majflt")
  data <- data[!colnames(data) %in% drop]

  data$cpu_pct <- as.numeric(sub("%$", "", data$cpu_pct)) / 100

  ## Add column 'pwd'
  pwd <- grep("PWD=", data$command, value=TRUE)
  pwd <- gsub("^.* PWD=", "", pwd)
  pwd <- dirname(pwd)
  pwd <- unique(pwd)
  stopifnot(length(pwd) == 1L)

  ## Add column 'drive'
  drive <- grep("TEST_DRIVE=", data$command, value=TRUE)
  drive <- gsub("^.* TEST_DRIVE=", "", drive)
  drive <- unique(drive)
  stopifnot(length(drive) == 1L)

  data <- cbind(data[,1:3], drive=drive, data[,-(1:3)])
  data <- tibble::as_tibble(data)

  ## Sanity checks
  stopifnot(any(duplicated(data$id)))
  stopifnot(any(duplicated(data$hostname)))
  stopifnot(any(duplicated(data$test_drive)))
  
  data
} ## read_bench_log()
