source("R/lcg.R")
lcg_set_seed(get_uid())

for (kk in 1:5) {
  message(lcg_port())
}

