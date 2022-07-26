#! /usr/bin/env bash

#' Check if TCP port can be opened
#'
#' Examples:
#' can_port_be_opened 4001
#' openable=$?
#'
#' Requirements:
#' * either 'nc' or 'ss'
can_port_be_opened() {
    local -i port=${1:?}
    
    (( port < 1 || port > 65535 )) && error "Port is out of range [1,65535]: ${port}"
    
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
        error "Neither command 'nc' nor 'ss' is available on this host ($HOSTNAME)"
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

#' Analogue to java_hashCode() but returns a non-signed integer
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

port4me_seed() {
    local user=${PORT4ME_USER:-${USER}}
    local tool=${PORT4ME_TOOL}
    local seed_str
    
    seed_str=
    if [[ -n $user && -n $tool ]]; then
        seed_str="$user,$tool"
    elif [[ -n $user ]]; then
        seed_str="$user"
    elif [[ -n $tool ]]; then
        seed_str="$tool"
    else
        error "At least one of arguments 'user' and 'tool' must be non-empty"
    fi

    string_to_uint "$seed_str"
}

parse_ports() {
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

port4me() {
    local -i max_tries=${PORT4ME_MAX_TRIES:-1000}
    local must_work=${PORT4ME_MUST_WORK:-true}
    local -i skip=${PORT4ME_SKIP:-0}
    local -i list=${PORT4ME_LIST:-0}
    local -i exclude include prepend
    local -i count

    mapfile -t exclude < <(parse_ports "${PORT4ME_EXCLUDE},${PORT4ME_EXCLUDE_SITE}")
    mapfile -t include < <(parse_ports "${PORT4ME_INCLUDE},${PORT4ME_INCLUDE_SITE}")
    mapfile -t prepend < <(parse_ports "${PORT4ME_PREPEND},${PORT4ME_PREPEND_SITE}")

    if (( list > 0 )); then
        max_tries=${list}
    fi
    
    LCG_SEED=$(port4me_seed)

    count=0
    while (( count < max_tries )); do
        if (( ${#prepend[@]} > 0 )); then
            port=${prepend[0]}
            (( port < 1 || port > 65535 )) && error "Prepended port out of range [1,65535]: ${port}"
            prepend=("${prepend[@]:1}") ## drop first element
        else
            lcg_port > /dev/null
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
    
            if can_port_be_opened "$port"; then
                printf "%d\n" "$port"
                return 0
            fi
            port=
        fi
    done

    if (( list == 0 )); then
        if $must_work; then
            error "Failed to find a free TCP port"
        fi

        printf "%d\n" "-1"
    fi
    
    return 0
}
