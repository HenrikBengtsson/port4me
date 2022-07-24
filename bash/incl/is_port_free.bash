#! /usr/bin/env bash

#' Check if TCP Port is Free
#'
#' Examples:
#' is_port_free 4001
#' is_free=$?
#'
#' Requirements:
#' * nc
is_port_free() {
    local -i port=${1:?}
    (( port < 1 || port > 65535 )) && error "Port is out of range [1,65535]: ${port}"
    if nc -z 127.0.0.1 "$port"; then
        return 1
    fi
    return 0
}
