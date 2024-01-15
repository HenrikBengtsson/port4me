#' Initialize R's internet module
#'
#' R needs to initialize its Internet module before we can create sockets.
#' This is automatically done when R starts on Linux and macOS, but not on
#' MS Windows.
#'
#' This function triggers the initialization, but calling one of R's
#' built-in functions that does so.  See 'src/main/internet.c' in the
#' R source code for where this happens under the hood.
#'
#' @noRd
initialize_internet <- local({
  done <- (.Platform[["OS.type"]] != "windows")
  baseenv <- baseenv()
  
  function() {
    ## Already done?
    if (done) return()
  
    if (exists("serverSocket", mode = "function", envir = baseenv, inherits = FALSE)) {
      ## R (>= 4.0.0)
      serverSocket <- get("serverSocket", mode = "function", envir = baseenv, inherits = FALSE)
      con <- serverSocket(port = 0L)
      close(con)
    } else {
      ## R (< 4.0.0)
      tryCatch({
        con <- socketConnection(port = 0L, server = FALSE, blocking = FALSE, timeout = 0.0)
        close(con)
      }, error = identity)
    }
    
    done <<- TRUE
  }
})


#' Check whether a TCP port is available
#'
#' @param port (integer) TCP port in $\[1,65535\]$ to test.
#'
#' @param test One or more tests to apply.
#' If `"bind"`, check if it is possible to _bind_ the TCP port.
#' If `"listen"`, check if it is possible to _listen_ to the TCP port.
#'
#' @return
#' Return TRUE if the TCP port is available, otherwise FALSE.
#'
#' @keywords internal
#' @noRd
is_tcp_port_available <- function(port, test = c("bind", "listen")) {
  stopifnot(
    length(port) == 1L,
    is.numeric(port),
    !is.na(port),
    port >= 1,
    port <= 65535
  )
  port <- as.integer(port)
  stopifnot(
    port >= 1L,
    port <= 65535L
  )

  test <- match.arg(test, several.ok = TRUE)

  ## SPECIAL: Fake port availability?
  if (nzchar(Sys.getenv("_PORT4ME_CHECK_AVAILABLE_PORTS_"))) {
    value <- Sys.getenv("_PORT4ME_CHECK_AVAILABLE_PORTS_")
    if (value == "any") {
#      warning("port4me:::is_tcp_port_available() returns TRUE because _PORT4ME_CHECK_AVAILABLE_PORTS_=any")
      return(TRUE)
    }
    stop("Unknown value on _PORT4ME_CHECK_AVAILABLE_PORTS_: ", sQuote(value))
  }

  initialize_internet()
  res <- .Call(C_R_test_tcp_port, port)
  
  if (nzchar(Sys.getenv("PORT4ME_DEBUG"))) {
    reason <- if (res == 0) {
      "available (can bind and listen)"
    } else if (res %/% 10 == 1) {
      "not available (cannot set up socket)"
    } else if (res %/% 10 == 2) {
      "not available (cannot reuse port in TIME_WAIT state)"
    } else if (res %/% 10 == 3) {
      "not available (cannot bind to port)"
    } else if (res %/% 10 == 4) {
      "not available (cannot listen)"
    }
    message(sprintf("port4me:::is_tcp_port_available(%d): %s", port, reason))
  }
  
  (res == 0L)
}
