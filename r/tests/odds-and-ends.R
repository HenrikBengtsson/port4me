library(port4me)

is_tcp_port_available <- port4me:::is_tcp_port_available
initialize_internet <- port4me:::initialize_internet
parse_cli_args <- port4me:::parse_cli_args

# --------------------------------------------------------
# is_tcp_port_available() and initialize_internet()
# --------------------------------------------------------
Sys.setenv("_PORT4ME_CHECK_AVAILABLE_PORTS_" = "<invalid>")
res <- tryCatch({
  is_tcp_port_available(1024)
}, error = identity)
stopifnot(inherits(res, "error"))
Sys.unsetenv("_PORT4ME_CHECK_AVAILABLE_PORTS_")

env <- environment(initialize_internet)
env[["done"]] <- FALSE
initialize_internet()

env <- environment(initialize_internet)
env[["done"]] <- FALSE
env[["baseenv"]] <- emptyenv()
initialize_internet()


# --------------------------------------------------------
# Test unloading package
# --------------------------------------------------------
unloadNamespace("port4me")

