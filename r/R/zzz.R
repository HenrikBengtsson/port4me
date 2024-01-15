#' @useDynLib "port4me", .registration = TRUE, .fixes = "C_"
.onUnload <- function(libpath) {
  library.dynam.unload(.packageName, libpath)
}
