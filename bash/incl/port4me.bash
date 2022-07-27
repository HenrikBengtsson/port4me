#! /usr/bin/env bash

declare -i LCG_SEED
export LCG_SEED

p4m_error() {
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
#' * either 'nc' or 'ss'
p4m_can_port_be_opened() {
    local -i port=${1:?}
    
    (( port < 1 || port > 65535 )) && p4m_error "Port is out of range [1,65535]: ${port}"
    
    ## Is port occupied?
    if command -v nc > /dev/null; then
        if nc -z 127.0.0.1 "$port"; then
            return 1
        fi
    elif command -v ss > /dev/null; then
        if ss -H -l -n src :"$port" | grep -q -E ":$port\b"; then
            return 1
        fi
    else
        p4m_error "Neither command 'nc' nor 'ss' is available on this host ($HOSTNAME)"
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

#' Analogue to Java hashCode() but returns a non-signed integer
p4m_string_to_uint() {
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

p4m_parse_ports() {
    local spec=${1:?}
    local specs
    local -a ports

    ## Prune input
    spec=${spec//,/ }
    spec=${spec//+( )/ }
    spec=${spec## }
    spec=${spec%% }
    spec=${spec// /$'\n'}

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

p4m_lcg() {
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
        p4m_error "INTERNAL: New LCG seed is non-positive: $seed_next, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    elif (( seed_next > modulus )); then
        p4m_error "INTERNAL: New LCG seed is too large: $seed_next, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    elif (( seed_next == seed )); then
        p4m_error "INTERNAL: New LCG seed is same a current seed, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    fi
    
    LCG_SEED=${seed_next}
    
    echo "${LCG_SEED}"
}

p4m_string_to_seed() {
    local seed=${PORT4ME_USER:-${USER:?}},${PORT4ME_TOOL}
    seed=${seed%%,}  ## trim trailing commas
    p4m_string_to_uint "$seed"
}

port4me() {
    local -i max_tries=${PORT4ME_MAX_TRIES:-65535}
    local must_work=${PORT4ME_MUST_WORK:-true}
    local -i skip=${PORT4ME_SKIP:-0}
    local -i list=${PORT4ME_LIST:-0}
    local -i exclude include prepend
    local -i count tries

    mapfile -t exclude < <(p4m_parse_ports "${PORT4ME_EXCLUDE},${PORT4ME_EXCLUDE_SITE}")
    mapfile -t include < <(p4m_parse_ports "${PORT4ME_INCLUDE},${PORT4ME_INCLUDE_SITE}")
    mapfile -t prepend < <(p4m_parse_ports "${PORT4ME_PREPEND},${PORT4ME_PREPEND_SITE}")

    if (( list > 0 )); then
        max_tries=${list}
    fi
    
    LCG_SEED=$(p4m_string_to_seed)

    count=0
    tries=0
    while (( tries < max_tries )); do
        tries=$(( tries + 1 ))
        
        if (( ${#prepend[@]} > 0 )); then
            port=${prepend[0]}
            (( port < 1 || port > 65535 )) && p4m_error "Prepended port out of range [1,65535]: ${port}"
            prepend=("${prepend[@]:1}") ## drop first element
        else
            p4m_lcg > /dev/null
            port=${LCG_SEED:?}
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
        elif (( LCG_SEED < 1024 || LCG_SEED > 65535 )); then
            continue
        fi

        count=$((count + 1))

        if (( list > 0 )); then
            printf "%d\n" "$port"
        else            
            ## Skip?
            if (( count <= skip )); then
                continue
            fi
            
            ${PORT4ME_DEBUG:-false} && >&2 printf "%d. port=%d\n" "$count" "$port"
    
            if p4m_can_port_be_opened "$port"; then
                printf "%d\n" "$port"
                return 0
            fi
            port=
        fi
    done

    if (( list == 0 )); then
        if $must_work; then
            p4m_error "Failed to find a free TCP port after ${max_tries} attempts"
        fi

        printf "%d\n" "-1"
    fi
    
    return 0
}
