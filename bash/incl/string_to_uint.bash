#! /usr/bin/env bash

#' Analogue to java_hashCode() but returns a non-signed
#' integers
string_to_uint() {
    local str="$1"
    local -i MAX_UINT=${PORT4ME_MAX_UINT:-$(( 2**32 ))}
    local -i kk byte
    local -i hash=0
    for ((kk = 0; kk < ${#str}; kk++)); do
        ## ASCII character to ASCII value
        LC_TYPE=C printf -v byte "%d" "'${str:$kk:1}"
        hash=$(( 31 * hash + byte ))
        ## Corce to non-signed integer [0,MAX_UINT-1]
        hash=$(( hash % MAX_UINT ))
#        printf "%2d. byte=%3d, hash=%.0f\n" $kk $byte $hash
    done
    
    printf "%d" $hash
}
