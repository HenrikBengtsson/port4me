#! /usr/bin/env bash

declare -i LCG_SEED

LCG_SEED=-1
export LCG_SEED

error() {
    >&2 echo "ERROR: $1"
    exit 1
}

lcg_set_seed() {
    local -i seed=${1:?}
    (( seed < 0 )) && error "LCG seed must be non-negative: $seed"
    LCG_SEED=${seed}
}

lcg_get_seed() {
    echo "${LCG_SEED:?}"
}


# shellcheck disable=SC2120
lcg() {
    local -i modulus=65537
    local -i a=75
    local -i c=74
    local -i seed
    local -i seed_next

    seed=$(lcg_get_seed)

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
        error "INTERNAL: New LCG seed is non-positive: $seed_next, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    elif (( seed_next > modulus )); then
        error "INTERNAL: New LCG seed is too large: $seed_next, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    elif (( seed_next == seed )); then
        error "INTERNAL: New LCG seed is same a current seed, where (a, c, modulus) = ($a, $c, $modulus) with seed = $seed"
    fi
    
    LCG_SEED=${seed_next}
    
    echo "${LCG_SEED}"
}

lcg_port() {
    local -i min=${1:-1024}
    local -i max=${2:-65535}
    local -i res
    
    while true; do
        res=$(lcg)
        LCG_SEED=${res}
        if (( res >= min && res <= max )); then
            break
        fi
    done
    
    echo "${res}"
}
