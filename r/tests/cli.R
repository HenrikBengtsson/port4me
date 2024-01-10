library(port4me)

Sys.setenv("_PORT4ME_CHECK_AVAILABLE_PORTS_" = "any")

# --------------------------------------------------------
# Test CLI app
# --------------------------------------------------------
message("CLI: No options (default)")
print(port4me)

message("CLI: Explicitly no options (default)")
options(.port4me.commandArgs = c())
print(port4me)

message("CLI: --debug")
options(.port4me.commandArgs = c("--debug"))
print(port4me)

message("CLI: --help")
options(.port4me.commandArgs = c("--help"))
print(port4me)

message("CLI: --version")
options(.port4me.commandArgs = c("--version"))
print(port4me)

message('CLI: --user="alice"')
options(.port4me.commandArgs = c('--user="alice"'))
print(port4me)

message('CLI: --user="alice" --tool="rstudio"')
options(.port4me.commandArgs = c('--user="alice"', '--tool="rstudio"'))
print(port4me)

message('CLI: --user="alice" rstudio')
options(.port4me.commandArgs = c('--user="alice"', 'rstudio'))
print(port4me)

message('CLI: --foo')
options(.port4me.commandArgs = c('--foo'))
res <- tryCatch({
  print(port4me)
}, error = identity)
stopifnot(inherits(res, "error"))

message('CLI: --foo=bar')
options(.port4me.commandArgs = c('--foo=bar'))
res <- tryCatch({
  print(port4me)
}, error = identity)
stopifnot(inherits(res, "error"))


message('CLI: --123')
options(.port4me.commandArgs = c('--123'))
res <- tryCatch({
  print(port4me)
}, error = identity)
stopifnot(inherits(res, "error"))


## This needs to be last, because it calls quit()
message('CLI: --test=80')
options(.port4me.commandArgs = c('--test=80'))
print(port4me)
