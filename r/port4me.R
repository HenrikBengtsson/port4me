main <- function() {
  for (ff in dir("R", pattern = "[.]R$", full.names = TRUE)) {
    source(ff, local = TRUE)
  }
  port <- do.call(port4me, args = parse_cli_args())
  cat(sprintf("%d\n", port))
}

main()

