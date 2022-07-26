#! /usr/bin/env bash

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
