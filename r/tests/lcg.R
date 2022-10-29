lcg_get_seed <- port4me:::lcg_get_seed
lcg_set_seed <- port4me:::lcg_set_seed
lcg_port <- port4me:::lcg_port
lcg <- port4me:::lcg


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


