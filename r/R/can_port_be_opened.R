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

  if (identical(can_listen_to_port(port), FALSE)) return(FALSE)
  can_bind_port(port)
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
#' @param timeout (numeric) Maximum number of seconds to try before
#' giving up.
#'
#' @return TRUE if the port can be bound, otherwise FALSE.
#' If it cannot be decided, NA is returned.
#'
#' @seealso
#' This function uses [base::socketConnection()] in a background R process
#' to test whether it is possible to _bind_ to the specified port.
#'
#' @keywords internal
#' @noRd
#'
#' @importFrom utils file_test
can_bind_port <- function(port, timeout = 5.0) {
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

  ## LAUNCH BACKGROUND PROCESS
  code <- sprintf("ack_file <- '%s'; cat(Sys.getpid(), file = ack_file); t0 <- Sys.time(); tryCatch({ con <- socketConnection('%s', port = %d, server = TRUE, blocking = TRUE, timeout = %f); close(con); cat('TRUE', file = ack_file) }, error = function(...) { cat('FALSE', file = ack_file) })", ack_file, hostname, port, timeout)
  parse(text = code)  ## validate code

  bin <- file.path(R.home("bin"), "Rscript")
  stopifnot(file_test("-f", bin))
  
  system2(bin, args = c("-e", shQuote(code)), wait = FALSE, stdout = nullfile(), stderr = nullfile())

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
} ## can_bind_port()
