for (ff in dir(c("../R", "R"), pattern = "[.]R$", full.names = TRUE)) {
  source(ff, local = TRUE)
}

message('- lcg_port() with seeds 0:65535')

for (seed in 0:65535) {
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


