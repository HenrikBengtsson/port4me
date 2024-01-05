#' Check whether a TCP port is free or not
#'
#' @param port (integer) A TCP port in \[1, 65535\].
#'
#' @return
#' `can_port_be_opened(port)` returns a logical indicating whether the port
#' can be opened or not, or cannot be queried.  If the port can be opened,
#' then `TRUE` is returned, if cannot be opened then `FALSE` is returned,
#' which may happen if the port is used by another process.
#' If it cannot be decided, NA is returned.
#' A port can be "opened" if it can be listened to and be bound.
#'
#' @keywords internal
#' @noRd
can_port_be_opened <- function(port) {
  ## SPECIAL: Fake port availability?
  if (nzchar(Sys.getenv("_PORT4ME_CHECK_AVAILABLE_PORTS_"))) {
    value <- Sys.getenv("_PORT4ME_CHECK_AVAILABLE_PORTS_")
    if (value == "any") {
      return(TRUE)
    }
    stop("Unknown value on _PORT4ME_CHECK_AVAILABLE_PORTS_: ", sQuote(value))
  }

  ## can_listen_to_port() may return NA
  if (identical(can_listen_to_port(port), FALSE)) return(FALSE)

  res <- can_bind_port(port)

  ## can_bind_port() may return NA
  if (is.na(res)) {
    warning("port4me: Can listen to TCP port, but could not infer if it is possible to bind to it; will assume not: ", port)
    res <- FALSE
  }

  res
}


#' Check whether it possible to listen to a TCP port
#'
#' @param port (integer) A TCP port in \[1, 65535\].
#'
#' @return
#' `can_port_be_opened(port)` returns a logical indicating whether the port
#' can be listened to, or cannot be queried.  If the port can be listened
#' to then `TRUE` is returned, and if not, then `FALSE` is returned, which
#' may happen if the port is used by another process.
#' If port querying is not supported, as in R (< 4.0.0),  then `NA` is
#' returned.
#'
#' @seealso
#' This function uses [base::serverSocket()] to test whether it is possible
#' to _listen_ to the specified port.
#'
#' @keywords internal
#' @noRd
can_listen_to_port <- function(port) {
  stopifnot(length(port) == 1, is.numeric(port), is.finite(port), port >= 1, port <= 65535)

  ## If not possible to query, return NA
  ## It works in R (>= 4.0.0)
  ns <- asNamespace("parallel")
  if (!exists("serverSocket", envir = ns, mode = "function")) return(NA)
  
  serverSocket <- get("serverSocket", envir = ns, mode = "function")

  ## suspendInterrupts() is available in R (>= 3.5.0), so we're good here,
  ## but we use this to avoid 'R CMD check' WARNINGs in R (< 3.5.0)
  suspendInterrupts <- get("suspendInterrupts", envir = asNamespace("base"), mode = "function")

  ## Prevent user interrupts from giving false results
  suspendInterrupts({
    ## Test if possible to listen to port
    con <- tryCatch(serverSocket(port), error = identity)
  })

  ## Success?
  free <- inherits(con, "connection")
  if (free) close(con)
  
  free
}


#' Check if a TCP port can be bound
#' 
#' @param port (numeric) port number to test
#'
#' @return TRUE if the port can be bound, otherwise FALSE.
#' If it cannot be decided, FALSE is returned.
#'
#' @keywords internal
#' @noRd
can_bind_port <- local({
  known_methods <- c("backgroundProcess", "startDynamicHelp")
  fail_count <- integer(length = 2L)
  names(fail_count) <- known_methods
  
  function(port, methods = getOption("port4me.test_methods", c("backgroundProcess", "startDynamicHelp"))) {
    stopifnot(is.character(methods), !any(is.na(methods)))
    
    unknown <- setdiff(methods, known_methods)
    if (length(unknown) > 0) {
      warning("Ignoring unknown values in R option 'port4me.test_method': ",
              paste(sQuote(unknown), collapse = ", "))
      methods <- unique(intersect(methods, known_methods))
    }
  
    ## Fall back to all known methods
    if (length(methods) == 0L) {
      methods <- known_methods
    }

    ## Ignore methods that failed more than 5 times (potential speedup)
    methods <- methods[fail_count[methods] <= 5L]

    ## If none of the methods work, we will keep trying all of them
    if (length(methods) == 0L) {
      methods <- known_methods
      fail_count[] <- 0L
    }

    res <- NA
    for (method in methods) {
      if (method == "startDynamicHelp") {
        can_bind_port_fcn <- can_bind_port_startDynamicHelp
      } else if (method == "backgroundProcess") {
        can_bind_port_fcn <- can_bind_port_backgroundProcess
      } else {
        next  ## Should never happen
      }

      res <- tryCatch(local({
        setTimeLimit(cpu = 10.0, elapsed = 10.0, transient = TRUE)
        on.exit({
          setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
        })
        can_bind_port_fcn(port)
      }), error = function(ex) {
        warning(conditionMessage(ex))
        NA
      })
      
      if (is.na(res)) {
        ## Unless previous success, memoize failures
        if (fail_count[method] >= 0L) {
          fail_count[method] <- fail_count[method] + 1L
        }
      } else {
        fail_count[method] <- -1L  ## Mark success (needed only once)
        return(res)
      }
    }
    
    res
  }
})


#' Check if a TCP port can be bound
#' 
#' @param timeout (numeric) Maximum number of seconds to try before
#' giving up.
#'
#' @details
#' This function uses [base::socketConnection()] in a background R process
#' to test whether it is possible to _bind_ to the specified port.
#'
#' @keywords internal
#' @noRd
#'
#' @importFrom utils file_test
can_bind_port_backgroundProcess <- function(port, timeout = 5.0) {
  stopifnot(
    length(port) == 1L,
    is.numeric(port),
    is.finite(port),
    port >= 0L,
    port <= 65535
  )

  stopifnot(
    length(timeout) == 1L,
    is.numeric(timeout),
    is.finite(timeout),
    timeout >=  1.0,
    timeout <= 60.0
  )

  port <- as.integer(port)
  hostname <- "127.0.0.1"
  
  ack_file <- tempfile()
  ## Always use forward slashes in paths
  ack_file <- gsub("\\", "/", ack_file, fixed = TRUE)
  
  ## LAUNCH BACKGROUND PROCESS
  code <- sprintf("ack_file <- '%s'; cat(Sys.getpid(), file = ack_file); t0 <- Sys.time(); tryCatch({ con <- socketConnection('%s', port = %d, server = TRUE, blocking = TRUE, timeout = %f); close(con); cat('TRUE', file = ack_file) }, error = function(...) { cat('FALSE', file = ack_file) })", ack_file, hostname, port, timeout)
  parse(text = code)  ## validate code

  bin <- file.path(R.home("bin"), "Rscript")
  if (!file_test("-f", bin)) {
    bin <- file.path(R.home("bin"), "Rscript.exe")
  }
  stopifnot(file_test("-f", bin))
  
  system2(bin, args = c("--vanilla", "-e", shQuote(code)), wait = FALSE, stdout = nullfile(), stderr = nullfile())

  ## Wait for ACK file
  t0 <- Sys.time()
  while (!file_test("-f", ack_file)) {
    Sys.sleep(0.1)
    ## Timeout?
    if (Sys.time() - t0 > timeout) return(FALSE)
  }

  ## Try to connect to background process
  con <- tryCatch(suppressWarnings({
    socketConnection(hostname, port = port, blocking = TRUE, timeout = timeout)
  }), error = function(...) NULL)
  if (inherits(con, "connection")) close(con)

  ## Wait for result in ACK file
  result <- NA_character_
  t0 <- Sys.time()
  repeat {
    result <- readLines(ack_file, n = 1L, warn = FALSE)
    if (result %in% c("TRUE", "FALSE")) break
    Sys.sleep(0.1)
    ## Timeout?
    if (Sys.time() - t0 > timeout) {
      break
    }
  }

  ## Remove
  file.remove(ack_file)

  identical(result, "TRUE")
} ## can_bind_port_bg_process()


#' @details
#' This function uses [tools::startDynamicHelp()] to test whether it
#' is possible to _bind_ to the specified port.
#' @keywords internal
#' @noRd
#'
#' @importFrom tools startDynamicHelp
can_bind_port_startDynamicHelp <- function(port) {
  stopifnot(
    length(port) == 1L,
    is.numeric(port),
    is.finite(port),
    port > 0, port <= 65535
  )
  
  ## Preserve original settings and state
  oenv <- Sys.getenv("R_DISABLE_HTTPD", NA_character_)
  oports <- getOption("help.ports", NULL)
  oport <- NA_integer_
  cport <- NA_integer_
  on.exit(suppressMessages({
    ## (a) Shut down temporarily dynamic help server, if still open
    if (!is.na(cport)) {
      tryCatch(startDynamicHelp(FALSE), error = identity)
    }
    
    ## (b) Reopen previously running dynamic help server
    if (!is.na(oport)) {
      options(help.ports = oport)
      port <- tryCatch(startDynamicHelp(TRUE), error = identity)
      if (inherits(port, "error")) {
        warning(sprintf("can_bind_port() failed to restart the dynamic help server on port %d. Please, try to call tools::startDynamicHelp(TRUE) manually", oport))
      } else if (port != oport) {
        warning(sprintf("can_bind_port() restarted the dynamic help server on a different port (%d) than before (%d)", port, oport))
      }
    }
    
    ## (c) Undo changes to R option 'help.ports'
    options(help.ports = oports)

    ## (c) Undo changes to environment variable 'R_DISABLE_HTTPD'
    if (is.na(oenv)) {
      Sys.unsetenv("R_DISABLE_HTTPD")
    } else {
      Sys.setenv("R_DISABLE_HTTPD" = oenv)
    }
  }))

  Sys.unsetenv("R_DISABLE_HTTPD")

  ## Stop dynamic help, if it's already running
  options(help.ports = 0L)
  oport <- tryCatch(suppressMessages({
    oport <- startDynamicHelp(NA)
    if (oport == 0L) {
      oport <- NA_integer_
    } else if (oport == port) {
      oport <- NA_integer_
      return(FALSE)
    } else {
      res <- startDynamicHelp(FALSE)
      stopifnot(res == 0L)
    }
    oport
  }), error = function(...) {
    NA_integer_
  })

  ## Retry to bind port 'port'
  options(help.ports = port)
  res <- tryCatch(suppressMessages({
    ## (a) Try to open dynamic help
    cport <- startDynamicHelp(TRUE)
    ## (b) Shut it down immediately, if successful
    ans <- startDynamicHelp(FALSE)
    if (ans == 0L) cport <- NA_integer_
    TRUE
  }), error = function(...) FALSE)

  res
}
