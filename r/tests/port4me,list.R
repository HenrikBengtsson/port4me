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


n <- 200e3
message(sprintf("- port4me(list = %d)", n))
ports <- port4me(list = n)
stopifnot(
  is.integer(ports),
  length(ports) == n,
  all(is.finite(ports)),
  all(ports > 0L),
  all(ports <= 65535L),
  all(ports >= 1024L)
)

## Statistical properties

## (a) range, because we draw a large enough sample)
stopifnot(
  min(ports) == 1024L,
  max(ports) == 65535L
)

t <- table(ports)
t2 <- table(t)
print(t2)

## Expected average draws per port
mu <- n / (65535 - 1024 + 1)
message(sprintf("Expected draws per port: %.4f", mu))
stopifnot(all(c(floor(mu), ceiling(mu)) == names(t2)))

mu_hat <- stats::weighted.mean(as.integer(names(t2)), w = t2)
message(sprintf("Observed draws per port: %.4f", mu_hat))

stopifnot(abs(mu_hat - mu) < 0.001)
