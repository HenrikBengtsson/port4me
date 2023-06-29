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


#' @export
print.cli_function <- function(x, ..., envir = parent.frame()) {
  if (interactive()) return(NextMethod())

  args <- parse_cli_args()
  str(args)
  
  res <- withVisible(do.call(port4me, args = args, envir = envir))
  
  # Should the result be printed?
  if (res$visible) {
    value <- res$value
    if (is.integer(value)) {
      cat(sprintf("%i\n", value), collapse = "", sep = "")
    } else if (is.logical(value)) {
      cat(sprintf("%s\n", value), collapse = "", sep = "")
    }
  }

  invisible()
}
