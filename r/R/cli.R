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
    } else if (grepl(pattern <- "^--([[:alnum:]]+)$", arg)) {
      name <- gsub(pattern, "\\1", arg)
      args[[name]] <- I(TRUE)
    } else if (grepl(pattern <- "^--", arg)) {
      stop(sprintf("Unknown command-line argument: %s", arg))
    } else {
      args[[length(args) + 1L]] <- arg
    }
    cli_args <- cli_args[-1]
  }
  
  args
}


cli_help_string <- '
port4me: Get the Same, Personal, Free TCP Port over and over

Usage:
 Rscript -e port4me::port4me [options]

Options:  
 --help             Display the full help page with examples
 --version          Output version of this software
 --debug            Output detailed debug information

 --user=<string>    User name (default: $USER)
 --tool=<string>    Name of software tool
 --include=<ports>  Set of ports to be included
                    (default: 1024-65535)
 --exclude=<ports>  Set of ports to be excluded
 --prepend=<ports>  Set of ports to be considered first

 --list=<n>         List the first \'n\', available or not, ports

 --test=<port>      Return 0 if port is available, otherwise 1

Examples:
Rscript -e port4me::port4me --version

Rscript -e port4me::port4me
Rscript -e port4me::port4me --tool=rstudio
Rscript -e port4me::port4me --include=11000-11999 --exclude=11500,11509 --tool=rstudio
Rscript -e port4me::port4me rstudio    ## short for --tool=rstudio

rserver --www-port "$(Rscript -e port4me::port4me rstudio)"
jupyter notebook --port "$(Rscript -e port4me::port4me jupyter-notebook)"

Rscript -e port4me::port4me --test=8087 && echo "free" || echo "taken"

Version: {{ version }}
Copyright: Henrik Bengtsson (2022-2023)
License: MIT
'


#' @importFrom utils packageVersion
#' @export
print.cli_function <- function(x, ..., envir = parent.frame()) {
  if (interactive()) return(NextMethod())

  args <- parse_cli_args()

  if (isTRUE(args$debug)) {
    Sys.setenv(PORT4ME_DEBUG = "true")
    args$debug <- NULL
  }

  if (isTRUE(args$version)) {
    cat(as.character(packageVersion(.packageName)), "\n", sep = "")
  } else if (isTRUE(args$help)) {
    msg <- cli_help_string
    msg <- sub("{{ version }}", packageVersion(.packageName), msg, fixed = TRUE)
    cat(msg)
  } else {
    res <- withVisible(do.call(port4me, args = args, envir = envir))
    
    # Should the result be printed?
    if (res$visible) {
      value <- res$value
      if (is.integer(value)) {
        cat(sprintf("%i\n", value), collapse = "", sep = "")
      } else if (is.logical(value)) {
        quit(save = "no", status = as.integer(!value))
      }
    }
  }
  invisible()
}
