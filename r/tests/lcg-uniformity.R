lcg_get_seed <- port4me:::lcg_get_seed
lcg_set_seed <- port4me:::lcg_set_seed
lcg_port <- port4me:::lcg_port
lcg <- port4me:::lcg
source("R/lcg.R")
lcg <- compiler::cmpfun(lcg)

a <- environment(lcg)[["a"]]
c <- environment(lcg)[["c"]]
m <- environment(lcg)[["modulus"]]
message(sprintf("- LCG parameters (a,c,m): (%d,%d,%d)", a, c, m))
stopifnot(a == 75L, c == 74L, m == 2^16+1)

seed <- 0L
message(sprintf("Initializing seed: %d", seed))
lcg_set_seed(seed = seed)

message("lcg() draws from all values in {0, ..., m-1} except one of them")
seeds <- 0:(m-1)
seeds_next <- (a * seeds + c) %% m
seed_skip <- seeds[seeds_next == seeds]
message(sprintf(" - Skipped seed: %s", seed_skip))
stopifnot(length(seed_skip) == 1L)

counts <- integer(length = m)
names(counts) <- seq(from = 0L, to = m - 1L)
counts[seed_skip + 1L] <- 1L

dt <- system.time({
for (kk in seq_len(m - 1L)) {
  idx <- lcg() + 1L
  stopifnot(idx >= 1L, idx <= m)
  counts[idx] <- counts[idx] + 1L
}
})
print(dt)
stopifnot(sum(counts) == m)
stopifnot(all(counts > 0L)) ## technically => all(counts == 1)


message("lcg() draws from uniformly from {0, ..., m-1} except one of them")

message("- Distribution of counts:")
dist <- table(counts)
names(dist) <- sprintf("n=%s", names(dist))
print(dist)
stopifnot(all(counts == 1L))
