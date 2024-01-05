## covr: skip=all
.onLoad <- function(libname, pkgname) {
  method <- Sys.getenv("_R_PORT4ME_TEST_METHOD_", NA_character_)
  if (!is.na(method)) {
    if (!is.element(method, c("startDynamicHelp", "backgroundProcess"))) {
      warning("port4me: Ignoring unknown value on environment variable '_R_PORT4ME_TEST_METHOD_': ", sQuote(method))
    } else {
      options(port4me.test_method = method)
    }
  }
}

