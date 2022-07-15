parse_cli_args <- function() {
  ## Parse command-line arguments
  cli_args <- commandArgs(trailingOnly = TRUE)
  
  args <- list()
  while (length(cli_args) > 0) {
    arg <- cli_args[1]
    if (grepl(pattern <- "^--([[:alnum:]]+)=(.*)$", arg)) {
      name <- gsub(pattern, "\\1", arg)
      value <- gsub(pattern, "\\2", arg)
      if (grepl("^[+-]?[[:digit:]]+$", value)) {
        value_int <- suppressWarnings(as.integer(value))
        if (!is.na(value_int)) value <- value_int
      }
      args[[name]] <- value
    } else {
      stop(sprintf("Unknown command-line argument: %s", arg))
    }
    cli_args <- cli_args[-1]
  }
  
  args
}
