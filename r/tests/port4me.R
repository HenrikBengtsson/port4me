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


message("- port4me() can detect busy port")
Sys.unsetenv("_PORT4ME_CHECK_AVAILABLE_PORTS_")
Sys.setenv("PORT4ME_DEBUG" = "true")
## Start dynamic help, if not already running, and get its port
port <- tools::startDynamicHelp(NA)
message("Dynamic help port: ", port)
res <- port4me(test = port)
message("Port is available: ", res)
stopifnot(identical(res, FALSE))
Sys.unsetenv("PORT4ME_DEBUG")



