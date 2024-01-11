library(port4me)

Sys.setenv(PORT4ME_USER = "alice")

truth <- c(30845, 19654, 32310, 63992, 15273, 31420, 62779, 55372, 24143, 41300)
message(sprintf("- port4me(list = %d)", length(truth)))
ports <- port4me(list = length(truth))
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


message('- port4me(user = "alice") with PORT4ME_LIST=10)')
Sys.setenv(PORT4ME_LIST = "10")
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
Sys.unsetenv("PORT4ME_LIST")
