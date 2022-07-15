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
