source("R/is_port_free.R")
source("R/lcg.R")
source("R/java_hashCode.R")

seed <- string_to_uint32("alice,rstudio")
lcg_set_seed(seed)
message(sprintf("Seed: %.0f", lcg_get_seed()))

skip <- as.integer(Sys.getenv("PORT4ME_SKIP", "0"))
stopifnot(is.numeric(skip), !is.na(skip))

for (kk in 1:5) {
  port <- lcg_port()
  if (kk <= skip) next
  message(port)
  if (is_port_free(port)) break
}

message(sprintf("Found a free port: %d", port))
