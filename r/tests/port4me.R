for (ff in dir(c("../R", "R"), pattern = "[.]R$", full.names = TRUE)) {
  source(ff, local = TRUE)
}

Sys.setenv(PORT4ME_USER = "alice")


message('- port4me(user = "alice", tool="rstudio")')
truth <- 23510L
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

truth <- c(31869, 20678, 33334, 65016, 16297, 32444, 63803, 56396, 25167, 42324)
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

n <- 40e3
message(sprintf("- port4me(list = %d)", n))
ports <- port4me(list = n)
stopifnot(
  is.integer(ports),
  length(ports) == n,
  all(is.finite(ports)),
  all(ports > 0L),
  all(ports <= 65535L),
  all(ports >= 1024L),
  min(ports) == 1024L,
  max(ports) == 65535L
)

