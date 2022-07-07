source("R/lcg.R")
lcg_set_seed(get_uid())

skip <- as.integer(Sys.getenv("PORT4ME_SKIP", "0"))
stopifnot(is.numeric(skip), !is.na(skip))

for (kk in 1:5) {
  port <- lcg_port()
  if (kk <= skip) next
  message(port)
}

