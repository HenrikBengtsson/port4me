#! /usr/bin/env bash

#' Check if TCP port can be opened
#'
#' Examples:
#' can_port_be_opened 4001
#' openable=$?
#'
#' Requirements:
#' * nc
can_port_be_opened() {
    local -i port=${1:?}
    
    (( port < 1 || port > 65535 )) && error "Port is out of range [1,65535]: ${port}"
    
    ## Check if port is free
    if nc -z 127.0.0.1 "$port"; then
        return 1
    fi
    
    ## FIXME: A port can be free, but it might be that the user
    ## don't have the right to open it, e.g. port 1-1023.
    
    return 0
}
