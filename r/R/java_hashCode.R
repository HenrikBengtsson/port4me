#' Examples:
#' $ java_hashCode ""
#' 0
#' $ java_hashCode "A"
#' 65
#' $ java_hashCode "Arnold"
#' 1969563338
#' $ java_hashCode "port4me - get the same, personal, free TCP port over and over"
#' 1731535982
#' $ java_hashCode "alice,rstudio"  ## FIXME
#' -606348900

java_asInt <- function(x) {
  Integer.MIN.VALUE <- -2147483648
  Integer.MAX.VALUE <-  2147483647
  Integer.RANGE <- Integer.MAX.VALUE - Integer.MIN.VALUE + 1
  x <- (x - Integer.MIN.VALUE) %% Integer.RANGE + Integer.MIN.VALUE
  as.integer(x)
}

java_hashCode <- function(str, ...) {
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
    # Convert into range of Java int.
    hash <- java_asInt(hash)
  }
    
  hash
} ## java_hashCode()


java_asUInt <- function(x) {
  Integer.MAX.VALUE <-  2^32
  x <- x %% Integer.MAX.VALUE
  x
}

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
    # Convert into range of Java int.
    hash <- java_asUInt(hash)
  }
    
  hash
} ## java_hashCode()
