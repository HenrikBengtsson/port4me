#! /usr/bin/env bash

port4me_user() {
    local res=${PORT4ME_USER}
    [[ -z $res ]] && res=${USER}
    echo "$res"
}

port4me_tool() {
    local res=${PORT4ME_TOOL}
    echo "$res"
}

port4me_seed() {
    local user tool seed_str
    local -i seed
    
    user=$(port4me_user)
    tool=$(port4me_tool)
    
    seed_str=
    if [[ -n $user &&  -n $tool ]]; then
        seed_str="$user,$tool"
    elif [[ -n $user ]]; then
        seed_str="$user"
    elif [[ -n $tool ]]; then
        seed_str="$tool"
    else
        error "At least one of arguments 'user' and 'tool' must be non-empty"
    fi

    seed=$(string_to_uint32 "$seed_str")

    if ${PORT4ME_DEBUG:-false}; then
       >&2 printf "seed_str='%s'\n" "$seed_str"
       >&2 printf "seed=%d\n" "$seed"
    fi
    
    echo "$seed"
}


port4me() {
    local -i skip=${PORT4ME_SKIP:-0}
    local -i exclude=${PORT4ME_EXCLUDE}
    local -i count
    local -i max_tries=${PORT4ME_MAX_TRIES:-1000}
    local must_work=${PORT4ME_MUST_WORK:-true}
    
    lcg_set_params
    lcg_set_seed "$(port4me_seed)"

    count=0
    while (( count < max_tries )); do
        lcg_port > /dev/null

        count=$((count + 1))
        ## Skip?
        if (( count <= skip )); then
            continue
        fi
        
        port=${LCG_INTEGER:?}
        ${PORT4ME_DEBUG:-false} && >&2 printf "%d. port=%d\n" "$kk" "$port"
        
        if is_port_free "$port"; then
            printf "%d\n" "$port"
            return 0
        fi
        port=
    done

    if $must_work; then
        error "Failed to find a free TCP port"
    fi

    printf "%d\n" "-1"
    return 0
}
