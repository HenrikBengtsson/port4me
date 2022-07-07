#' Linear Congruential Generator
#'
#' @return
#' An integer in `{0, 1, ..., modulus-1}`.
#'
#' @reference
#' https://en.wikipedia.org/wiki/Linear_congruential_generator
lcg <- local({
  .seed <- NULL
  
  function(modulus = getOption("lcg.params")["modulus"], a = getOption("lcg.params")["a"], c = getOption("lcg.params")["c"], seed = NULL) {
    if (!is.null(seed)) {
      if (is.na(seed)) return(.seed)
      stopifnot(length(seed) == 1L, is.numeric(seed), !is.na(seed))
      .seed <<- seed
      return(invisible(.seed))
    }
    
    if (is.null(.seed)) {
      stop("Argument 'seed' must be specified at least once")
    }

    ## Set default LCG parameters, if not already set
    if (is.null(getOption("lcg.params"))) {
      lcg_set_params()
    }
    
    if (is.null(modulus)) modulus <- getOption("lcg.params")["modulus"]
    if (is.null(a)) a <- getOption("lcg.params")["a"]
    if (is.null(c)) c <- getOption("lcg.params")["c"]

    stopifnot(
      length(modulus) == 1L, is.numeric(modulus), !is.na(modulus),
      length(a) == 1L, is.numeric(a), !is.na(a),
      length(c) == 1L, is.numeric(c), !is.na(c)
    )

    .seed <<- (a * .seed + c) %% modulus
    
    .seed
  }
})

#' The default LCG parameters are $modulus = 2^16+1$, $a = 75$, and $c = 74$,
#' which are small enough to to be handled by Bash.  They also happens to be
#' the one used by the fabolous Sinclair ZX81.
lcg_set_params <- function(modulus = 2^16+1, a = 75, c = 74) {
  stopifnot(
    length(modulus) == 1L, is.numeric(modulus), !is.na(modulus),
    length(a) == 1L, is.numeric(a), !is.na(a),
    length(c) == 1L, is.numeric(c), !is.na(c)
  )
  options(lcg.params = c(modulus = modulus, a = a, c = c))
}

lcg_set_seed <- function(seed) {
  lcg(seed = seed)
}

lcg_get_seed <- function() {
  lcg(seed = NA_integer_)
}

lcg_integer <- function(min, max) {
  stopifnot(
    length(min) == 1L, is.numeric(min), !is.na(min),
    length(max) == 1L, is.numeric(max), !is.na(max),
    min <= max
  )
  lcg() %% (max - min) + min
}

lcg_port <- function(min = 1024, max = 65535) {
  lcg_integer(min = min, max = max)
}

get_uid <- function() {
  res <- system2("id", args = "-u", stdout = TRUE)
  as.integer(res)
}
