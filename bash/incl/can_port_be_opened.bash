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
    
    ## Is port occupied?
    if command -v nc > /dev/null; then
        if nc -z 127.0.0.1 "$port"; then
            return 1
        fi
    else
        error "Command 'nc' is not available on this host ($HOSTNAME)"
    fi
    
    ## FIXME: A port can be free, but it might be that the user
    ## don't have the right to open it, e.g. port 1-1023.
    ## WORKAROUND: If non-root, assume 1-1023 can't be opened
    if [[ "$EUID" != 0 ]]; then
        if (( port < 1024 )); then
            return 1
        fi
    fi
    
    return 0
}
