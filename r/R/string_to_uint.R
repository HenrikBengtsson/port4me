port4me_max_uint <- local({
  max <- NULL
  function(reset = FALSE) {
    if (is.null(max) || isTRUE(reset)) {
      value <- Sys.getenv("PORT4ME_MAX_UINT", "4294967296") ## = 2^32
      value <- as.numeric(value)
      stopifnot(is.finite(value))
      max <<- value
    }
    max
  }
})

string_to_uint <- function(str) {
  stopifnot(is.character(str), length(str) == 1L, !is.na(str))
  max_uint <- port4me_max_uint()
  
  #  The hashcode for a character string is computed as
  #
  #    s[1]*31^(n-1) + s[2]*31^(n-2) + ... + s[n]
  #
  #  using int arithmetic, where s[i] is the i:th character of the
  #  string, n is the length of the string. The hash value of the
  #  empty string is zero.
  raw <- charToRaw(str)
  if (length(raw) == 0) return(0)
  bytes <- as.integer(raw)
  hash <- 0
  for (kk in seq_along(bytes)) {
    hash <- 31 * hash + bytes[kk]
    # Convert into [0,max_uint-1] range
    hash <- hash %% max_uint
  }
    
  hash
}
