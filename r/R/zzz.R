## covr: skip=all
.onLoad <- function(libname, pkgname) {
  methods <- Sys.getenv("_R_PORT4ME_TEST_METHODS_", NA_character_)
  if (!is.na(methods)) {
    methods <- strsplit(methods, split = ",", fixed = TRUE)[[1]]
    methods <- gsub("(^[[:blank:]]*|[[:blank:]]*$)", "", methods)
    known_methods <- c("startDynamicHelp", "backgroundProcess")
    unknown <- setdiff(methods, known_methods)
    if (length(unknown) > 0) {
      warning("port4me: Ignoring unknown methods in environment variable '_R_PORT4ME_TEST_METHODS_': ", paste(sQuote(unknown), collapse = ", "))
      methods <- intersect(methods, known_methods)
    }
    if (length(methods) > 0) {
      options(port4me.test_method = methods)
    }
  }
}
