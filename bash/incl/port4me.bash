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
#' Warning:
#' Then smaller the set of ports that PORT4ME_INCLUDE, PORT4ME_EXCLUDE, etc.
#' define, the longer the run time will be.
#'
#' Requirements:
#' * Bash (>= 4)
#'
#' Version: 0.7.0
#' Copyright: Henrik Bengtsson (2022-2024)
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

_p4m_signal_error() {
    if grep -q -E "ERROR<<<(.*)>>>" <<< "$*"; then
        _p4m_error "$(sed -E "s/.*ERROR<<<(.*)>>>,*/\1/g" <<< "$*")"
    fi
}

_p4m_assert_integer() {
    if grep -q -E "^[[:digit:]]+$" <<< "$*"; then
        _p4m_error "Not an integer: $*"
    fi
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

    ## SPECIAL: Fake port availability?
    if [[ -n ${_PORT4ME_CHECK_AVAILABLE_PORTS_} ]]; then
        if [[ ${_PORT4ME_CHECK_AVAILABLE_PORTS_} == "any" ]]; then
            return 0
        fi
        _p4m_error "Unknown value on _PORT4ME_CHECK_AVAILABLE_PORTS_: ${_PORT4ME_CHECK_AVAILABLE_PORTS_}"
    fi
    
    ## Identify port command and memoize, unless already done
    if [[ -z ${PORT4ME_PORT_COMMAND} ]]; then
        for cmd in "${cmds[@]}"; do
            if command -v "${cmd}" > /dev/null; then
                PORT4ME_PORT_COMMAND=${cmd}
                break
            fi
        done
        [[ -z ${PORT4ME_PORT_COMMAND} ]] && _p4m_error "Cannot check if port is available or not. None of the following commands exist on this system: ${cmds[*]}"
    else
        command -v "${PORT4ME_PORT_COMMAND}" > /dev/null || _p4m_error "Commands not found: ${PORT4ME_PORT_COMMAND}"
    fi

    ${PORT4ME_DEBUG:-false} && >&2 echo "Checking TCP port using '${PORT4ME_PORT_COMMAND}'"
    
    ## Is port occupied?
    if [[ ${PORT4ME_PORT_COMMAND} == "ss" ]]; then
	## -t, --tcp           Display TCP sockets.
        ## -n, --numeric       Do not try to resolve service names.
        ## -a, --all           Display both listening and non-listening (for
        ##                     TCP this means established connections) sockets.
        ## -H, --no-header     Suppress header line.
        ## EXPRESSION:
        ## {dst|src} [=] HOST  Test if the destination or source matches HOST.
        if ss -t -n -a -H "src = :${port}" | grep -q -E ":$port\b"; then
	    ## occupied?
            return 1
        fi
    elif [[ ${PORT4ME_PORT_COMMAND} == "netstat" ]]; then
        ## "[netstat] is mostly obsolete. Replacement for netstat is ss."
        ## Source: 'man netstat'
        ## netstat:
        ## -t, --tcp
        ## -n, --numeric    Show numerical addresses instead of trying to
        ##                  determine symbolic host, port or user names
        ## -a, --all        Show both listening and non-listening sockets. 
        ## State:
        ## CLOSE_WAIT       The remote end has shut down, waiting for the
        ##                  socket to close.
        ## ESTABLISHED      The socket has an established connection.
        ## LISTEN           The socket is listening for incoming connections.
        if netstat -t -n -a | grep -q -E "^tcp\b[^:]+:$port\b.*(CLOSE_WAIT|ESTABLISHED|LISTEN)"; then
	    ## occupied?
            return 1
        fi
    elif [[ ${PORT4ME_PORT_COMMAND} == "ncat" ]]; then
        ## -l, --listen     Bind and listen for incoming connections.
        ##                  Listen for connections rather than connecting
        ##                  to a remote machine.
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
    local sort=${2:-true}
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
    spec=$(uniq <<< "${spec}")
    if $sort; then
        spec=$(sort -u <<< "${spec}")
    fi

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
            ## Ignore '0':s. The is required, because on MS Windows, we cannot
            ## distinguish from set and unset environment variables, meaning we
            ## need to use PORT4ME_EXCLUDE_UNSAFE="0", because "" would trigger
            ## the default value.
            if [[ $spec != "0" ]]; then
                ports+=("$spec")
            fi
        elif grep -q -E "^[[:blank:]]*$" <<< "$spec"; then
            true
        else
            echo "ERROR<<<Unknown port specification: ${spec}>>>"
            return 0
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
        ## NOTE: I don't think this can ever happen with above modulo
        _p4m_error "INTERNAL: New LCG seed is non-positive: $seed_next, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    elif (( seed_next > modulus )); then
        ## NOTE: I don't think this can ever happen with above modulo
        _p4m_error "INTERNAL: New LCG seed is too large: $seed_next, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    elif (( seed_next == seed )); then
        _p4m_error "INTERNAL: New LCG seed is same a current seed, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    fi
    
    LCG_SEED=${seed_next}
    
    echo "${LCG_SEED}"
}


_p4m_lcg_port() {
    local -i min=${1:?}
    local -i max=${2:?}
    local -i count
    local -a subset
    local has_subset=false
    local subset_str=""
    local ready=false

    if [[ $# -gt 2 ]]; then    
        shift
        shift
        subset=("$@")
        
        ## NOTE: 'subset' must be sorted.
        min=${subset[0]}
        max=${subset[-1]}
        subset_str=" ${subset[*]} "
        has_subset=true
    fi

    if ${PORT4ME_DEBUG}; then
        {
            echo "(min,max): ($min,$max)"
            echo "subset: [n=${#subset[@]}]"
        } >&3
    fi
    
    ## Sample values in [0,m-2] (sic!), but reject until in [min,max],
    ## or in 'subset' set.
    count=65536
    while ! ${ready}; do
        _p4m_lcg > /dev/null

        ## Accept?
        if (( LCG_SEED >= min && LCG_SEED <= max )); then
            if ${has_subset}; then
                ## Within 'subset'?
                if [[ ${subset_str} == *" $LCG_SEED "* ]]; then
                    ready=true
                fi
            else
                ## Within [min,max]?
                ready=true
            fi
        fi

        count=$((count - 1))
        if [[ $count -lt 0 ]]; then
            _p4m_error "[INTERNAL]: _p4m_lcg_port() did not find a port after 65536 attempts"
        fi
    done
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

    local -a exclude include prepend
    local -i count tries tmp_int

    ## Assert Bash (>= 4)
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        _p4m_error "port4me requires Bash (>= 4): ${BASH_VERSION}. As a workaround, you could install the Python version (python -m pip port4me) and define a Bash function as: port4me() { python -m port4me \"\$@\"; }"
    fi

    ## Validate arguments
    if [[ -n ${PORT4ME_TEST} ]]; then
        if ! grep -q -E "^[[:digit:]]+$" <<< "${PORT4ME_TEST}"; then
            _p4m_error "PORT4ME_TEST is not an integer: ${PORT4ME_TEST}"
        fi
        tmp_int=${PORT4ME_TEST}
        if (( tmp_int < 1 || tmp_int > 65535 )); then
            _p4m_error "PORT4ME_TEST is out of range [1,65535]: ${tmp_int}"
        fi
    fi
    
    ## Check port availability?
    if [[ $test -ne 0 ]]; then
        _p4m_can_port_be_opened "${test}"
        return $?
    fi

    if [[ -n ${PORT4ME_LIST} ]]; then
        if ! grep -q -E "^[[:digit:]]+$" <<< "${PORT4ME_LIST}"; then
            _p4m_error "PORT4ME_LIST is not an integer: ${PORT4ME_LIST}"
        fi
        tmp_int=${PORT4ME_LIST}
        if (( tmp_int < 1 )); then
            _p4m_error "PORT4ME_LIST must not be postive: ${tmp_int}"
        fi
    fi

    if [[ -n ${PORT4ME_SKIP} ]]; then
        if ! grep -q -E "^[[:digit:]]+$" <<< "${PORT4ME_SKIP}"; then
            _p4m_error "PORT4ME_SKIP is not an integer: ${PORT4ME_SKIP}"
        fi
        tmp_int=${PORT4ME_SKIP}
        if (( tmp_int < 0 )); then
            _p4m_error "PORT4ME_SKIP must not be negative: ${tmp_int}"
        fi
    fi
    
    mapfile -t exclude < <(_p4m_parse_ports "${PORT4ME_EXCLUDE},${PORT4ME_EXCLUDE_SITE},${PORT4ME_EXCLUDE_UNSAFE}")
    _p4m_signal_error "${exclude[@]}"

    mapfile -t include < <(_p4m_parse_ports "${PORT4ME_INCLUDE},${PORT4ME_INCLUDE_SITE}")
    _p4m_signal_error "${include[@]}"
    
    mapfile -t prepend < <(_p4m_parse_ports "${PORT4ME_PREPEND},${PORT4ME_PREPEND_SITE}" false)
    _p4m_signal_error "${prepend[@]}"

    if ${PORT4ME_DEBUG:-false}; then
        {
            echo "PORT4ME_EXCLUDE=${PORT4ME_EXCLUDE:-<not set>}"
            echo "PORT4ME_EXCLUDE_SITE=${PORT4ME_EXCLUDE_SITE:-<not set>}"
            echo "PORT4ME_EXCLUDE_UNSAFE=${PORT4ME_EXCLUDE_UNSAFE:-<not set>}"
            echo "PORT4ME_INCLUDE=${PORT4ME_INCLUDE:-<not set>}"
            echo "PORT4ME_INCLUDE_SITE=${PORT4ME_INCLUDE_SITE:-<not set>}"
            echo "PORT4ME_PREPEND=${PORT4ME_PREPEND:-<not set>}"
            echo "PORT4ME_PREPEND_SITE=${PORT4ME_PREPEND_SITE:-<not set>}"
            echo "PORT4ME_SKIP=${PORT4ME_SKIP:-<not set>}"
            echo "PORT4ME_LIST=${PORT4ME_LIST:-<not set>}"
            echo "PORT4ME_TEST=${PORT4ME_TEST:-<not set>}"
            echo "Ports to prepend: [n=${#prepend}] ${prepend[*]}"
            echo "Ports to include: [n=${#include}] ${include[*]}"
            echo "Ports to exclude: [n=${#exclude}] ${exclude[*]}"
        } >&2
    fi

    if (( list > 0 )); then
        max_tries=${list}
    fi

    
    subset=()

    if [[ ${#include[@]} -gt 0 ]] || [[ ${#exclude[@]} -gt 0 ]]; then
        ## Include?
        if [[ ${#include[@]} -gt 0 ]]; then
            ## Make sure to sort 'include'; required by _p4m_lcg_port()
            mapfile -t subset < <(printf "%s\n" "${include[@]}" | sort -n -u)
        else
           mapfile -t subset < <(seq 1024 65535)
        fi

        ## Exclude?
        if [[ ${#exclude[@]} -gt 0 ]]; then
            ## Make sure to sort 'exclude'; required by _p4m_lcg_port()
            mapfile -t subset < <(diff --new-line-format="" --unchanged-line-format="" <(printf "%d\n" "${subset[@]}") <(printf "%d\n" "${exclude[@]}" | sort -n -u))
        fi
        
        if ${PORT4ME_DEBUG:-false}; then
            >&2 echo "Ports to consider: [n=${#subset[@]}] ${subset[*]}"
        fi
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
            _p4m_lcg_port 1024 65535 "${subset[@]}"
            port=${LCG_SEED:?}
            ${PORT4ME_DEBUG:-false} && >&2 printf "Port drawn: %d\n" "$port"
        fi

        count=$((count + 1))

        ## Skip?
        if (( count <= skip )); then
            continue
        fi

        tries=$(( tries + 1 ))
        
        if (( list > 0 )); then
            printf "%d\n" "$port"
        else            
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
