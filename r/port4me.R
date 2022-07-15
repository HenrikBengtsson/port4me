source("R/is_port_free.R")
source("R/lcg.R")
source("R/java_hashCode.R")
source("R/port4me.R")
source("R/parse_cli_args.R")

port <- do.call(port4me, args = parse_cli_args())
cat(sprintf("%d\n", port))
