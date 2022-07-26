#' Linear Congruential Generator
#'
#' @param seed (optional) Initiates the LCG seed, iff specified.
#'
#' @return
#' An integer in `{0, 1, ..., modulus-1}`, if `standardize = FALSE`,
#' or a numeric in `[0,1)`, if `standardize = TRUE`,
#'
#' @details
#' The LCG parameters are $modulus = 2^16+1$, $a = 75$, and $c = 74$,
#' which are small enough to to be handled by Bash.  They also happens to be
#' the one used by the fabolous Sinclair ZX81.
#'
#' @references
#' https://en.wikipedia.org/wiki/Linear_congruential_generator
#'
#' @noRd
lcg <- local({
  ## LCG parameters
  modulus <- 2^16+1
  a <- 75
  c <- 74
  
  .seed <- NULL
  
  function(seed = NULL) {
    if (!is.null(seed)) {
      if (is.na(seed)) return(.seed)
      stopifnot(length(seed) == 1L, is.numeric(seed), !is.na(seed), seed >= 0)
      ## Make sure seed is within [0,modulus-1] to avoid integer overflow
      seed <- seed %% modulus
      .seed <<- seed
      return(invisible(.seed))
    }
    
    if (is.null(.seed)) {
      stop("Argument 'seed' must be specified at least once")
    }

    seed <- .seed
    seed_next <- (a * seed + c) %% modulus

    ## For certain LCG parameter settings, we might end up in the same
    ## LCG state. For example, this can happen when (a-c) = 1 and
    ## seed = modulus-1. To make sure we handle any parameter setup, we
    ## detect this manually, increment the seed, and recalculate.
    if (seed_next == seed) {
        seed <- seed + 1
        seed_next <- (a * seed + c) %% modulus
    }

    ## Sanity check
    stopifnot(length(seed_next) == 1L, is.numeric(seed_next), !is.na(seed_next))

    ## Sanity checks
    if (seed_next < 0) {
        stop(sprintf("New LCG seed is negative (%.0f), which could be because non-functional LCG parameters: (a, c, modulus) = (%.0f, %.0f, %.0f) with seed = %.0f", seed_next, a, c, modulus, seed))
    } else if (seed_next > modulus) {
        stop(sprintf("New LCG seed is too large (%.0f), which could be because non-functional LCG parameters: (a, c, modulus) = (%.0f, %.0f, %.0f) with seed = %.0f", seed_next, a, c, modulus, seed))
    } else if (seed_next  == seed) {
        stop(sprintf("New LCG seed is same a current seed, with (a, c, modulus) = (%.0f, %.0f, %.0f) with seed = %.0f", a, c, modulus, seed))
    }

    .seed <<- seed_next
  }
})


lcg_set_seed <- function(seed) {
  lcg(seed = seed)
}

lcg_get_seed <- function() {
  lcg(seed = NA_integer_)
}

lcg_port <- function(min = 1024, max = 65535) {
  ## Sample values in [0,m-2] (sic!), but reject until in [1024,65535]
  repeat {
    res <- lcg()
    if (res >= min && res <= max) break
  }
  as.integer(res)
}
