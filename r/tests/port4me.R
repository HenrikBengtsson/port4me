for (ff in dir("R", pattern = "[.]R$", full.names = TRUE)) {
  source(ff, local = TRUE)
}

Sys.setenv(PORT4ME_USER = "alice")
Sys.setenv(PORT4ME_MAX_UINT = "4294967296")
port4me_max_uint(reset = TRUE)

message("- port4me(list = 10)")
n <- 10L
ports <- port4me(list = n)
stopifnot(
  is.integer(ports),
  length(ports) == n,
  all(is.finite(ports)),
  all(ports > 0L),
  all(ports <= 65535L),
  all(ports >= 1024L)
)


message("- port4me(list = 100e3)")
n <- 100e3
ports <- port4me(list = n)
stopifnot(
  is.integer(ports),
  length(ports) == n,
  all(is.finite(ports)),
  all(ports > 0L),
  all(ports <= 65535L),
  all(ports >= 1024L)
)
print(range(ports))
