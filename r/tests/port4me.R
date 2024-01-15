library(port4me)

Sys.setenv("_PORT4ME_CHECK_AVAILABLE_PORTS_" = "any")

message('- port4me(user = "alice")')
truth <- 30845L
ports <- port4me(user = "alice")
print(ports)
stopifnot(
  is.integer(ports),
  all(is.finite(ports)),
  all(ports > 0L),
  all(ports <= 65535L),
  all(ports >= 1024L),
  length(ports) == length(truth),
  all(ports == truth)
)


message('- port4me(user = "bob")')
truth <- 54242L
ports <- port4me(user = "bob")
print(ports)
stopifnot(
  is.integer(ports),
  all(is.finite(ports)),
  all(ports > 0L),
  all(ports <= 65535L),
  all(ports >= 1024L),
  length(ports) == length(truth),
  all(ports == truth)
)


message('- port4me(user = "alice", tool = "rstudio")')
truth <- 22486L
ports <- port4me(user = "alice", tool="rstudio")
print(ports)
stopifnot(
  is.integer(ports),
  all(is.finite(ports)),
  all(ports > 0L),
  all(ports <= 65535L),
  all(ports >= 1024L),
  length(ports) == length(truth),
  all(ports == truth)
)


message('- port4me(user = "alice") with PORT4ME_TOOL=rstudio)')
Sys.setenv(PORT4ME_TOOL = "rstudio")
truth <- 22486L
ports <- port4me(user = "alice")
print(ports)
stopifnot(
  is.integer(ports),
  all(is.finite(ports)),
  all(ports > 0L),
  all(ports <= 65535L),
  all(ports >= 1024L),
  length(ports) == length(truth),
  all(ports == truth)
)
Sys.unsetenv("PORT4ME_TOOL")


message('- port4me(user = "alice", tool = "jupyter-notebook")')
truth <- 29525L
ports <- port4me(user = "alice", tool="jupyter-notebook")
print(ports)
stopifnot(
  is.integer(ports),
  all(is.finite(ports)),
  all(ports > 0L),
  all(ports <= 65535L),
  all(ports >= 1024L),
  length(ports) == length(truth),
  all(ports == truth)
)

message('- port4me() with PORT4ME_USER=alice')
Sys.setenv(PORT4ME_USER = "alice")
truth <- 30845L
ports <- port4me()
print(ports)
stopifnot(
  is.integer(ports),
  all(is.finite(ports)),
  all(ports > 0L),
  all(ports <= 65535L),
  all(ports >= 1024L),
  length(ports) == length(truth),
  all(ports == truth)
)


truth <- c(30845, 19654, 32310, 63992, 15273, 31420, 62779, 55372, 24143, 41300)
exclude <- c(30845, 32310)
message(sprintf("- port4me(exclude = c(%s))", paste(exclude, collapse = ", ")))
port <- port4me(exclude = exclude)
print(port)
stopifnot(
  length(port) == 1L,
  is.integer(port),
  is.finite(port),
  port > 0L,
  port <= 65535L,
  port >= 1024L,
  port == setdiff(truth, exclude)[1]
)


message(sprintf("- port4me() with PORT4ME_EXCLUDE=%s", paste(exclude, collapse = ", ")))
Sys.setenv(PORT4ME_EXCLUDE = paste(exclude, collapse = ","))
port <- port4me()
print(port)
stopifnot(
  length(port) == 1L,
  is.integer(port),
  is.finite(port),
  port > 0L,
  port <= 65535L,
  port >= 1024L,
  port == setdiff(truth, exclude)[1]
)
Sys.unsetenv("PORT4ME_EXCLUDE")


include <- c(2000:2123, 4321, 10000:10999)
message("- port4me(include = c(2000:2123, 4321, 10000:10999))")
port <- port4me(include = include)
print(port)
stopifnot(
  length(port) == 1L,
  is.integer(port),
  is.finite(port),
  port > 0L,
  port <= 65535L,
  port >= 1024L,
  port == 10451L
)


include <- c(2000:2123, 4321, 10000:10999)
message("- port4me() with PORT4ME_INCLUDE=...")
Sys.setenv(PORT4ME_INCLUDE = paste(include, collapse = ","))
port <- port4me()
print(port)
stopifnot(
  length(port) == 1L,
  is.integer(port),
  is.finite(port),
  port > 0L,
  port <= 65535L,
  port >= 1024L,
  port == 10451L
)
Sys.unsetenv("PORT4ME_INCLUDE")


message('- port4me(exclude = "1024-1099")')
port <- port4me(exclude = "1024-1099")

message('- port4me(include = "1024-1099")')
port <- port4me(include = "1024-1099")

message('- port4me(prepend = "1024-1099")')
port <- port4me(prepend = "1024-1099")

prepend <- c(2000:2123, 4321, 10000:10999)
message("- port4me(prepend = c(2000:2123, 4321, 10000:10999))")
port <- port4me(prepend = prepend)
print(port)
stopifnot(
  length(port) == 1L,
  is.integer(port),
  is.finite(port),
  port > 0L,
  port <= 65535L,
  port >= 1024L,
  port == prepend[1]
)



message("- port4me(skip = 1L)")
port <- port4me(user = "alice", skip = 1L)
print(port)
stopifnot(
  length(port) == 1L,
  is.integer(port),
  is.finite(port),
  port > 0L,
  port <= 65535L,
  port >= 1024L,
  port == 19654L
)


# -------------------------------------------------------
# Check TCP port
# -------------------------------------------------------
message("- port4me() can detect busy port")
Sys.unsetenv("_PORT4ME_CHECK_AVAILABLE_PORTS_")
port <- NA_integer_
if (.Platform[["OS.type"]] == "unix" && Sys.info()[["sysname"]] != "Darwin") {
  ## Start dynamic help, if not already running, and get its port
  ## HELP WANTED: On both macOS and MS Windows, this port is still
  ## available. Why?
  ## system("python -m port4me --test=<port>") confirms this.
  ## /HB 2024-01-06
  port <- tools::startDynamicHelp(NA)
  message("Dynamic help port: ", port)
}

if (!is.na(port)) {
  Sys.setenv(PORT4ME_DEBUG = "true")
  
  res <- port4me(test = port)
  message(sprintf("port4me(test = %d) == %s", port, res))
  stopifnot(identical(res, FALSE))

  Sys.setenv(PORT4ME_TEST = port)
  res <- port4me()
  message(sprintf("Sys.setenv('PORT4ME_TEST'='%d'); port4me() == %s", port, res))
  stopifnot(identical(res, FALSE))
  Sys.unsetenv("PORT4ME_TEST")

  res <- tryCatch({
    port4me(include = port, exclude = setdiff(1:65535, port), max_tries = 1L)
  }, error = identity)
  stopifnot(inherits(res, "error"))

  res <- port4me(include = port, exclude = setdiff(1:65535, port), max_tries = 1L, must_work = FALSE)
  stopifnot(res == -1L)

  Sys.unsetenv("PORT4ME_DEBUG")
} else {
  message("Skipping; don't know how to test on ", sQuote(.Platform[["OS.type"]]))
}



# -------------------------------------------------------
# Exceptions
# -------------------------------------------------------
message('- port4me(user = "") produces an error')
res <- tryCatch({
  port4me(user = "")
}, error = identity)
stopifnot(inherits(res, "error"))


message('- port4me(include = "<invalid>") produces an error')
res <- tryCatch({
  port4me(include = "<invalid>")
}, error = identity)
stopifnot(inherits(res, "error"))



# -------------------------------------------------------
# Addition tests to increase test coverage
# -------------------------------------------------------
message('- port4me() with PORT4ME_DEBUG = true')
Sys.setenv(PORT4ME_DEBUG = "true")
port <- port4me()
print(port)
