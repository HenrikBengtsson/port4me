#' @export
print.cli_function <- function(x, ..., envir = parent.frame()) {
  if (interactive()) return(NextMethod())

  args <- parse_cli_args()
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
