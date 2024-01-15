lcg_get_seed <- port4me:::lcg_get_seed
lcg_set_seed <- port4me:::lcg_set_seed
lcg_port <- port4me:::lcg_port
lcg <- port4me:::lcg

a <- environment(lcg)[["a"]]
c <- environment(lcg)[["c"]]
m <- environment(lcg)[["modulus"]]
message(sprintf("- LCG parameters (a,c,m): (%d,%d,%d)", a, c, m))
stopifnot(a == 75L, c == 74L, m == 2^16+1)


message("lcg_port() draws uniformly from {min, ..., max}")

assert_lcg_port <- function(min = 1024L, max = 65535L, subset = NULL, seed = 0L) {
  if (is.null(subset)) {
    n <- max - min + 1L
    ports <- min:max
  } else {
    min <- min(subset)
    max <- max(subset)
    n <- length(subset)
    ports <- subset
  }
  
  counts <- integer(length = n)
  names(counts) <- ports
  
  lcg_set_seed(seed = seed)
  
  for (kk in seq_len(n)) {
    port <- lcg_port(min = min, max = max, subset = subset)
    stopifnot(port >= min, port <= max)
    if (is.null(subset)) {
      idx <- port - min + 1L
    } else {
      idx <- which(port == ports)
    }
    stopifnot(!is.na(idx), idx >= 1L, idx <= n)
    counts[idx] <- counts[idx] + 1L
  }
  stopifnot(sum(counts) == n)
  
  message("- Distribution of counts:")
  dist <- table(counts)
  names(dist) <- sprintf("n=%s", names(dist))
  print(dist)
  stopifnot(all(counts == 1L))
} ## assert_lcg_port()


message("lcg_port() draws uniformly from {1024, ..., 65535}")
assert_lcg_port()

message("lcg_port() draws uniformly from {1024, ..., 65535} regardless of seed")
assert_lcg_port(seed = 1L)
assert_lcg_port(seed = 42L)
assert_lcg_port(seed = 65535L)

message("lcg_port(min = 1) draws uniformly from {1, ..., 65535}")
assert_lcg_port(min = 1)

message("lcg_port(min = 50, max = 100) draws uniformly from {50, ..., 100}")
assert_lcg_port(min = 50, max = 100)

message("lcg_port(subset = 50:100) draws uniformly from {50, ..., 100}")
assert_lcg_port(subset = 50:100)

message("lcg_port(subset = seq(1, 65535, by = 5)) draws uniformly from {1, 5, ..., 65535}")
assert_lcg_port(subset = seq(1, 65535, by = 5))



message("lcg() draws from all values in {0, ..., m-1} except one of them")
seeds <- 0:(m-1)
seeds_next <- (a * seeds + c) %% m
seed_skip <- seeds[seeds_next == seeds]
message(sprintf(" - Skipped seed: %s", seed_skip))
stopifnot(length(seed_skip) == 1L)

counts <- integer(length = m)
names(counts) <- seq(from = 0L, to = m - 1L)
counts[seed_skip + 1L] <- 1L

seed <- 0L
message(sprintf("Initializing seed: %d", seed))
lcg_set_seed(seed = seed)

for (kk in seq_len(m - 1L)) {
  idx <- lcg() + 1L
  stopifnot(idx >= 1L, idx <= m)
  counts[idx] <- counts[idx] + 1L
}

stopifnot(sum(counts) == m)
stopifnot(all(counts > 0L)) ## technically => all(counts == 1)


message("lcg() draws from uniformly from {0, ..., m-1} except one of them")

message("- Distribution of counts:")
dist <- table(counts)
names(dist) <- sprintf("n=%s", names(dist))
print(dist)
stopifnot(all(counts == 1L))
