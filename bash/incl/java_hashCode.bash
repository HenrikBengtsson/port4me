#! /usr/bin/env bash

#' Algorithm
#' h[n] = s[1]*31^(n-1) + s[2]*31^(n-2) + ... + s[n]
#' =>
#' h[0] = 0
#' h[1] = s[1]
#' h[2] = h[1]*31 + s[2]
#' h[3] = h[2]*31 + s[3]
#' ...
#' h[n] = h[n-1]*31 + s[n]
#'
#' Examples:
#' $ java_hashCode ""
#' 0
#' $ java_hashCode "A"
#' 65
#' $ java_hashCode "Arnold"
#' 1969563338
#' $ java_hashCode "port4me - get the same, personal, free TCP port over and over"
#' 1731535982
#' $ java_hashCode "alice,rstudio"
#' -606348900
#'
#' Adopted from https://stackoverflow.com/a/48863502/1072091
#' Validated via https://www.online-java.com/
java_hashCode() {
    local str="$1"
    local -i MAX_UINT=$(( 2**32 ))
    local -i MAX_INT=2147483647   ## +2^31-1
    local -i MIN_INT=-2147483648  ## -2^31
    local -i kk byte
    local -i hash=0
    for ((kk = 0; kk < ${#str}; kk++)); do
        ## ASCII character to ASCII value
        LC_TYPE=C printf -v byte "%d" "'${str:$kk:1}"
        hash=$(( 31 * hash + byte ))
        ## Corce to signed int32 [-2^31,+2^31-1]
        hash=$(( (hash - MIN_INT) % MAX_UINT ))
        (( hash < 0 )) && hash=$(( hash + MAX_UINT ))
        hash=$(( hash + MIN_INT ))
#        printf "%2d. byte=%3d, hash=%.0f\n" $kk $byte $hash
    done
    
    printf "%d" $hash
}


#' Analogue to java_hashCode() but returns a non-signed
#' 32-bit integer
string_to_uint32() {
    local str="$1"
    local -i MAX_UINT=$(( 2**32 ))
    local -i kk byte
    local -i hash=0
    for ((kk = 0; kk < ${#str}; kk++)); do
        ## ASCII character to ASCII value
        LC_TYPE=C printf -v byte "%d" "'${str:$kk:1}"
        hash=$(( 31 * hash + byte ))
        ## Corce to non-signed integer [0,2^32]
        hash=$(( hash % MAX_UINT ))
#        printf "%2d. byte=%3d, hash=%.0f\n" $kk $byte $hash
    done
    
    printf "%d" $hash
}
