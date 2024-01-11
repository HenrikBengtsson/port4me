library(port4me)
lcg_set_seed <- port4me:::lcg_set_seed

Sys.setenv("_PORT4ME_CHECK_AVAILABLE_PORTS_" = "any")
Sys.setenv("PORT4ME_EXCLUDE_UNSAFE" = "0")
Sys.setenv(PORT4ME_USER = "alice")

assert_port4me <- function(min = 1024L, max = 65535L, seed = 0L) {
  n <- max - min + 1L
  message(sprintf(" - sample size: %d", n))

  counts <- integer(length = n)
  names(counts) <- min:max
  
  lcg_set_seed(seed = seed)
  ports <- port4me(list = n)
  message(sprintf(" - sample: [n=%d] %s ...", n, paste(head(ports), collapse = " ")))
  message(sprintf(" - range: [%d, %d]", min(ports), max(ports)))
  stopifnot(ports >= min, ports <= max)

  ## Tally
  idxs <- ports - min + 1L
  stopifnot(all(idxs >= 1L), all(idxs <= n))
  for (idx in idxs) {
    counts[idx] <- counts[idx] + 1L
  }
  stopifnot(sum(counts) == n)
  
  message("- Distribution of counts:")
  dist <- table(counts)
  names(dist) <- sprintf("n=%s", names(dist))
  print(dist)
  stopifnot(all(counts == 1L))
} ## assert_port4me()

message("assert_port4me() draws uniformly from {1024, ..., 65535}")
assert_port4me()
