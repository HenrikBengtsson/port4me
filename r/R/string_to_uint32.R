string_to_uint32 <- function(str, ...) {
  stopifnot(is.character(str), length(str) == 1L, !is.na(str))
  
  #  The hashcode for a character string is computed as
  #
  #    s[1]*31^(n-1) + s[2]*31^(n-2) + ... + s[n]
  #
  #  using int arithmetic, where s[i] is the i:th character of the
  #  string, n is the length of the string. The hash value of the
  #  empty string is zero.
  raw <- charToRaw(str)
  if (length(raw) == 0) return(0L)
  bytes <- as.integer(raw)
  hash <- 0
  for (kk in seq_along(bytes)) {
    hash <- 31 * hash + bytes[kk]
    # Convert into [0,2^32-1] range
    hash <- hash %% 2^32
  }
    
  hash
}
