#! /usr/bin/env bash

declare -i LCG_SEED
declare -i LCG_PARAMS_MODULUS
declare -i LCG_PARAMS_A
declare -i LCG_PARAMS_C
declare -i LCG_INTEGER

LCG_SEED=-1
export LCG_SEED

error() {
    >&2 echo "ERROR: $1"
    exit 1
}

lcg_set_params() {
    local -i modulus=${1:-65537}
    local -i a=${2:-75}
    local -i c=${3:-74}
    (( a <= 0 )) && error "LCG parameter 'a' must be positive: $a"
    (( c <= 0 )) && error "LCG parameter 'c' must be positive: $c"
    (( modulus <= 0 )) && error "LCG parameter 'modulus' must be positive: $modulus"
    LCG_PARAMS_MODULUS=${modulus}
    LCG_PARAMS_A=${a}
    LCG_PARAMS_C=${c}
}

lcg_set_seed() {
    local -i seed=${1:?}
    (( seed <= 0 )) && error "LCG seed must be positive: $seed"
    LCG_SEED=${seed}
}

lcg_get_seed() {
    echo "${LCG_SEED:?}"
}


# shellcheck disable=SC2120
lcg() {
    local -i modulus=${1:-${LCG_PARAMS_MODULUS:-65537}}
    local -i a=${2:-${LCG_PARAMS_A:-75}}
    local -i c=${3:-${LCG_PARAMS_C:-74}}
    local -i seed
    local -i seed_next

    (( a <= 0 )) && error "LCG parameter 'a' must be positive: $a"
    (( c <= 0 )) && error "LCG parameter 'c' must be positive: $c"
    (( modulus <= 0 )) && error "LCG parameter 'modulus' must be positive: $modulus"

    seed=$(lcg_get_seed)
    ## Make sure seed is within [0,modulus-1] to avoid integer overflow
    seed=$(( seed % modulus ))
    seed_next=$(( (a * seed + c) % modulus ))

    ## Sanity checks
    if (( seed_next < 0 )); then
        error "INTERNAL: New LCG seed is non-positive: $seed_next, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    elif (( seed_next > modulus )); then
        error "INTERNAL: New LCG seed is too large: $seed_next, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    elif (( seed_next == seed )); then
        error "INTERNAL: New LCG seed is same a current seed, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    fi
    
    LCG_SEED=${seed_next}
    
    echo "${LCG_SEED}"
}

lcg_integer() {
    local -i min=${1:?}
    local -i max=${2:?}
    local -i seed res
    seed=$(lcg)
    LCG_SEED=${seed}
    
    res=$(bc <<< "${seed} % (${max} - ${min} + 1) + ${min}")

    ## Sanity checks
    if (( res < min || res > max )); then
        error "INTERNAL: Generated LCG integer is not in [$min,$max]: $res"
    fi

    ## Export LCG integer as environment variable too
    # shellcheck disable=SC2034
    LCG_INTEGER=${res}
    
    echo "${res}"
}

lcg_port() {
    local -i min=${1:-1024}
    local -i max=${2:-65535}
    lcg_integer "${min}" "${max}"
}
