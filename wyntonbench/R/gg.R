#' @importFrom tidyr gather
#' @importFrom dplyr select
#' @importFrom ggplot2 ggplot aes geom_line
#' @export
gg_uptime <- function(data, which = c("users", "load_1min")) {
  ## To please R CMD check
  timestamp <- value <- variable <- NULL
  
  known_which <- c("users", "load_1min", "load_5min", "load_15min")
  which <- match.arg(which, known_which, several.ok=TRUE)
  
  stopifnot(is.data.frame(data),
            all(known_which %in% colnames(data)))
  stopifnot(nrow(data) > 0)
  
  data <- data[, c("timestamp", which)]
  data <- gather(data, key="variable", value="value", -timestamp)

  gg <- ggplot(data, aes(x=timestamp, y=value))
  gg <- gg + geom_line(aes(color=variable, linetype=variable))
  gg
}
