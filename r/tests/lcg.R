lcg_get_seed <- port4me:::lcg_get_seed
lcg_set_seed <- port4me:::lcg_set_seed
lcg_port <- port4me:::lcg_port
lcg <- port4me:::lcg

if (!exists("params", mode = "list")) {
  params <- as.list(environment(lcg))
}
for (name in names(params)) {
  assign(name, params[[name]], envir = environment(lcg))
}

message('- lcg() with seed m-1 = 65536 (special case)')
seed <- 65536L
cat(sprintf("seed=%d\n", seed))
lcg_set_seed(seed)
stopifnot(lcg_get_seed() == seed)
seed_next <- lcg()
stopifnot(
  length(seed_next) == 1,
  is.numeric(seed_next),
  is.finite(seed_next),
  seed_next >= 0,
  seed_next <= 65536,
  seed_next == 74
)


message('- lcg_port() with seeds 0:65536')
for (seed in c(0:65536)) {
  cat(sprintf("\rseed=%d", seed))
  lcg_set_seed(seed)
  port <- lcg_port()
  stopifnot(
    length(port) == 1,
    is.integer(port),
    is.finite(port),
    port >= 0L,
    port <= 65535L,
    port >= 1024L
  )
}
cat("\r             \n")


# -------------------------------------------------------
# Exceptions
# -------------------------------------------------------
env <- environment(lcg)
env[[".seed"]] <- NULL

message('- lcg(NULL) produces an error if seed is not set first')
res <- tryCatch({
  lcg(NULL)
}, error = identity)
stopifnot(inherits(res, "error"))

## Set seed
lcg(42)

message('- lcg(NULL) does not produce an error after seed is set')
lcg(NULL)


message('- lcg() with (a,c) = (1,0) produces an error')
env[["a"]] <- 1L
env[["c"]] <- 0L
res <- tryCatch({
  lcg()
}, error = identity)
stopifnot(inherits(res, "error"))


# -------------------------------------------------------
# Cleanup
# -------------------------------------------------------
for (name in names(params)) {
  assign(name, params[[name]], envir = environment(lcg))
}
