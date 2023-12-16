#! /usr/bin/env bash

#' port4me: Get the Same, Personal, Free TCP Port over and over
#'
#' This Bash script is a self-contained version of the port4me tool.
#' It provides function port4me() that takes a set of environment
#' variables as input:
#'
#' - PORT4ME_USER   : The name of the current user (default: ${USER})
#' - PORT4ME_TOOL   : The name of the software tool (optional)
#' - PORT4ME_PREPEND: Ports to be considered first (optional)
#' - PORT4ME_INCLUDE: Ports to be considered (default: 1024-65535)
#' - PORT4ME_EXCLUDE: Ports to be excluded (optional)
#' - PORT4ME_EXCLUDE_UNSAFE:
#'                    Ports to be excluded because they are considered
#'                    unsafe (defaults: {chrome},{firefox})
#' - PORT4ME_EXCLUDE_UNSAFE_CHROME: Ports blocked by the Chrome browser
#' - PORT4ME_EXCLUDE_UNSAFE_FIREFOX: Ports blocked by the Firefox browser
#' - PORT4ME_SKIP   : Number of ports to skip in the set of ports
#'                    considered after applying prepended, included,
#'                    and excluded (optional)
#' - PORT4ME_LIST   : Number of ports to list regardless of
#'                    availability (optional)
#' - PORT4ME_TEST   : Port to check if it is available (optional)
#'
#' Examples:
#' port4me
#' PORT4ME_TOOL=jupyter_lab port4me
#' PORT4ME_EXCLUDE=8787 port4me
#' PORT4ME_PREPEND=4001-4003 port4me
#' PORT4ME_LIST=5 port4me
#' PORT4ME_TEST=4321 port4me && echo "free" || echo "taken"
#'
#' Requirements:
#' * Bash (>= 4)
#'
#' Version: 0.6.0-9007
#' Copyright: Henrik Bengtsson (2022-2023)
#' License: MIT
#' Source code: https://github.com/HenrikBengtsson/port4me
declare -i LCG_SEED
export LCG_SEED

PORT4ME_EXCLUDE_UNSAFE=${PORT4ME_EXCLUDE_UNSAFE:-"{chrome},{firefox}"}
export PORT4ME_EXCLUDE_UNSAFE

## Source: https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc
## Last updated: 2022-10-24
PORT4ME_EXCLUDE_UNSAFE_CHROME=${PORT4ME_EXCLUDE_UNSAFE_CHROME:-"1,7,9,11,13,15,17,19,20,21,22,23,25,37,42,43,53,69,77,79,87,95,101,102,103,104,109,110,111,113,115,117,119,123,135,137,139,143,161,179,389,427,465,512,513,514,515,526,530,531,532,540,548,554,556,563,587,601,636,989,990,993,995,1719,1720,1723,2049,3659,4045,5060,5061,6000,6566,6665,6666,6667,6668,6669,6697,10080"}

## Source: https://www-archive.mozilla.org/projects/netlib/portbanning#portlist
## Last updated: 2022-10-24
PORT4ME_EXCLUDE_UNSAFE_FIREFOX=${PORT4ME_EXCLUDE_UNSAFE_FIREFOX:-"1,7,9,11,13,15,17,19,20,21,22,23,25,37,42,43,53,77,79,87,95,101,102,103,104,109,110,111,113,115,117,119,123,135,139,143,179,389,465,512,513,514,515,526,530,531,532,540,556,563,587,601,636,993,995,2049,4045,6000"}

_p4m_error() {
    >&2 echo "ERROR: $1"
    exit 1
}

#' Check if TCP port can be opened
#'
#' Examples:
#' can_port_be_opened 4001
#' openable=$?
#'
#' Requirements:
#' * either 'netstat', 'ss', or 'ncat'
PORT4ME_PORT_COMMAND=${PORT4ME_PORT_COMMAND:-}
_p4m_can_port_be_opened() {
    local -i port=${1:?}
    local -i res
    local cmds=(netstat ss ncat)
    local cmd
    
    (( port < 1 || port > 65535 )) && _p4m_error "Port is out of range [1,65535]: ${port}"

    ## Identify port command and memoize, unless already done
    if [[ -z ${PORT4ME_PORT_COMMAND} ]]; then
        for cmd in "${cmds[@]}"; do
            if command -v "${cmd}" > /dev/null; then
                PORT4ME_PORT_COMMAND=${cmd}
                break
            fi
        done
        [[ -z ${PORT4ME_PORT_COMMAND} ]] && _p4m_error "Cannot check if port is available or not. None of the following commands exist on this system: ${cmds[*]}"
    fi

    ${PORT4ME_DEBUG:-false} && >&2 echo "Checking TCP port using '${PORT4ME_PORT_COMMAND}'"
    
    ## Is port occupied?
    if [[ ${PORT4ME_PORT_COMMAND} == "ss" ]]; then
	## -t == --tcp, -u == udp, -H = --no-header, -l = --listening, -n = --numeric
        if ss -H -t -u -l -n "src = :${port}" | grep -q -E ":$port\b"; then
	    ## occupied?
            return 1
        fi
    elif [[ ${PORT4ME_PORT_COMMAND} == "netstat" ]]; then
        if netstat -n -l -t | grep -q -E "^tcp\b[^:]+:$port\b"; then
	    ## occupied?
            return 1
        fi
    elif [[ ${PORT4ME_PORT_COMMAND} == "ncat" ]]; then
	timeout 0.1 ncat -l "$port" 2> /dev/null
	res=$?
        if [[ ${res} -eq 2 ]]; then
	    ## occupied?
            return 1
        fi
    fi

    ## FIXME: A port can be free, but it might be that the user
    ## don't have the right to open it, e.g. port 1-1023.
    ## WORKAROUND: If non-root, assume 1-1023 can't be opened
    if [[ "$EUID" != 0 ]]; then
        if (( port < 1024 )); then
	    ## as-it was occupied
            return 1
        fi
    fi

    ## free
    return 0
}

#' Analogue to Java hashCode() but returns a non-signed integer
_p4m_string_to_uint() {
    local str="$1"
    local -i kk byte
    local -i hash=0
    
    for ((kk = 0; kk < ${#str}; kk++)); do
        ## ASCII character to ASCII value
        LC_TYPE=C printf -v byte "%d" "'${str:$kk:1}"
        hash=$(( 31 * hash + byte ))
        ## Corce to non-signed integer [0,2^32-1]
        hash=$(( hash % 2**32 ))
    done
    
    printf "%d" $hash
}


_p4m_parse_ports() {
    local spec=${1:?}
    local specs
    local -a ports
    
    ## Prune and pre-parse input
    spec=${spec//\{chrome\}/${PORT4ME_EXCLUDE_UNSAFE_CHROME}}
    spec=${spec//\{firefox\}/${PORT4ME_EXCLUDE_UNSAFE_FIREFOX}}
    spec=${spec//,/ }
    spec=${spec//+( )/ }
    spec=${spec## }
    spec=${spec%% }
    spec=${spec// /$'\n'}
    spec=$(sort -n -u <<< "${spec}")

    ## Split input into lines
    mapfile -t specs <<< "${spec}"

    pattern="([[:digit:]]+)"
    for spec in "${specs[@]}"; do
        if grep -q -E "^${pattern}-${pattern}$" <<< "$spec"; then
            from=$(sed -E "s/${pattern}-${pattern}/\1/" <<< "$spec")
            to=$(sed -E "s/${pattern}-${pattern}/\2/" <<< "$spec")
            # shellcheck disable=SC2207
            ports+=($(seq "$from" "$to"))
        elif grep -q -E "^${pattern}$" <<< "$spec"; then
            ports+=("$spec")
        fi
    done
    
    if (( ${#ports[@]} > 0 )); then
        printf "%s\n" "${ports[@]}"
    fi
}

_p4m_lcg() {
    local -i a=75 c=74 modulus=65537 seed="${LCG_SEED:?}"
    local -i seed_next

    ## Make sure seed is within [0,modulus-1] to avoid integer overflow
    seed=$(( seed % modulus ))

    seed_next=$(( (a * seed + c) % modulus ))

    ## For certain LCG parameter settings, we might end up in the same
    ## LCG state. For example, this can happen when (a-c) = 1 and
    ## seed = modulus-1. To make sure we handle any parameter setup, we
    ## detect this manually, increment the seed, and recalculate.
    if (( seed_next == seed )); then
        seed=$(( seed + 1 ))
        seed_next=$(( (a * seed + c) % modulus ))
    fi

    ## Sanity checks
    if (( seed_next < 0 )); then
        _p4m_error "INTERNAL: New LCG seed is non-positive: $seed_next, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    elif (( seed_next > modulus )); then
        _p4m_error "INTERNAL: New LCG seed is too large: $seed_next, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    elif (( seed_next == seed )); then
        _p4m_error "INTERNAL: New LCG seed is same a current seed, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    fi
    
    LCG_SEED=${seed_next}
    
    echo "${LCG_SEED}"
}

_p4m_string_to_seed() {
    local seed=${PORT4ME_USER:-${USER:?}},${PORT4ME_TOOL}
    seed=${seed%%,}  ## trim trailing commas
    _p4m_string_to_uint "$seed"
}

port4me() {
    local -i max_tries=${PORT4ME_MAX_TRIES:-65535}
    local must_work=${PORT4ME_MUST_WORK:-true}
    local -i skip=${PORT4ME_SKIP:-0}
    local -i list=${PORT4ME_LIST:-0}
    local -i test=${PORT4ME_TEST:-0}

    local -i exclude include prepend
    local -i count tries

    ## Assert Bash (>= 4)
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        _p4m_error "port4me requires Bash (>= 4): ${BASH_VERSION}"
    fi
    
    if [[ $test -ne 0 ]]; then
        _p4m_can_port_be_opened "${test}"
        return $?
    fi
    
    mapfile -t exclude < <(_p4m_parse_ports "${PORT4ME_EXCLUDE},${PORT4ME_EXCLUDE_SITE},${PORT4ME_EXCLUDE_UNSAFE}")
    mapfile -t include < <(_p4m_parse_ports "${PORT4ME_INCLUDE},${PORT4ME_INCLUDE_SITE}")
    mapfile -t prepend < <(_p4m_parse_ports "${PORT4ME_PREPEND},${PORT4ME_PREPEND_SITE}")
    if ${PORT4ME_DEBUG:-false}; then
        {
            echo "PORT4ME_EXCLUDE=${PORT4ME_EXCLUDE}"
            echo "PORT4ME_EXCLUDE_SITE=${PORT4ME_EXCLUDE_SITE}"
            echo "PORT4ME_EXCLUDE_UNSAFE=${PORT4ME_EXCLUDE_UNSAFE}"
            echo "PORT4ME_INCLUDE=${PORT4ME_INCLUDE}"
            echo "PORT4ME_INCLUDE_SITE=${PORT4ME_INCLUDE_SITE}"
            echo "PORT4ME_PREPEND=${PORT4ME_PREPEND}"
            echo "PORT4ME_PREPEND_SITE=${PORT4ME_PREPEND_SITE}"
            echo "Ports to prepend: [n=${#prepend}] ${prepend[*]}"
            echo "Ports to include: [n=${#include}] ${include[*]}"
            echo "Ports to exclude: [n=${#exclude}] ${exclude[*]}"
        } >&2
    fi

    if (( list > 0 )); then
        max_tries=${list}
    fi
    
    LCG_SEED=$(_p4m_string_to_seed)

    count=0
    tries=0
    while (( tries < max_tries )); do
        if (( ${#prepend[@]} > 0 )); then
            port=${prepend[0]}
            ${PORT4ME_DEBUG:-false} && >&2 printf "Port prepended: %d\n" "$port"
            (( port < 1 || port > 65535 )) && _p4m_error "Prepended port out of range [1,65535]: ${port}"
            prepend=("${prepend[@]:1}") ## drop first element
        else
            _p4m_lcg > /dev/null
            
            ## Skip?
            if (( LCG_SEED < 1024 || LCG_SEED > 65535 )); then
              ${PORT4ME_DEBUG:-false} && >&2 printf "Skip to next, because LCG_SEED is out of range: %d\n" "$LCG_SEED"
              continue
            fi
            
            port=${LCG_SEED:?}
            ${PORT4ME_DEBUG:-false} && >&2 printf "Port drawn: %d\n" "$port"
        fi

        ## Skip?
        if (( ${#exclude[@]} > 0 )); then
            if [[ " ${exclude[*]} " == *" $port "* ]]; then
                ${PORT4ME_DEBUG:-false} && >&2 printf "Port excluded: %d\n" "$port"
                continue
            fi
        fi

        ## Not included?
        if (( ${#include[@]} > 0 )); then
            if [[ " ${include[*]} " != *" $port "* ]]; then
                ${PORT4ME_DEBUG:-false} && >&2 printf "Port not included: %d\n" "$port"
                continue
            fi
        fi
        
        tries=$(( tries + 1 ))
        count=$((count + 1))

        if (( list > 0 )); then
            printf "%d\n" "$port"
        else            
            ## Skip?
            if (( count <= skip )); then
                continue
            fi
            
            ${PORT4ME_DEBUG:-false} && >&2 printf "%d. port=%d\n" "$count" "$port"
    
            if _p4m_can_port_be_opened "$port"; then
                printf "%d\n" "$port"
                return 0
            fi
            port=
        fi
    done

    if (( list == 0 )); then
        if $must_work; then
            _p4m_error "Failed to find a free TCP port after ${max_tries} attempts"
        fi

        printf "%d\n" "-1"
    fi
    
    return 0
}
