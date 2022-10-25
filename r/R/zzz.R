.onLoad <- function(libname, pkgname) {
  register_vignette_engine_during_build_only(pkgname)
}
