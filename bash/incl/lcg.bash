#! /usr/bin/env bash

LCG_SEED=
export LCG_SEED

lcg_set_params() {
    local modulus=${1:-65537}
    local a=${2:-75}
    local c=${3:-74}
    LCG_PARAMS_MODULUS=${modulus}
    LCG_PARAMS_A=${a}
    LCG_PARAMS_C=${c}
}

lcg_set_seed() {
    LCG_SEED=${1:?}
}

lcg_get_seed() {
    echo "${LCG_SEED:?}"
}

lcg() {
    local -i modulus=${1:-${LCG_PARAMS_MODULUS:-65537}}
    local -i a=${2:-${LCG_PARAMS_A:-75}}
    local -i c=${3:-${LCG_PARAMS_C:-74}}
    local -i seed=$(lcg_get_seed)
    
    LCG_SEED=$(( (a * seed + c) % modulus ))
    echo "${LCG_SEED}"
}

lcg_integer() {
    local -i min=${1:?}
    local -i max=${2:?}
    local -i seed
    seed=$(lcg)
    LCG_SEED=${seed}
    bc <<< "${seed} % (${max} - ${min}) + ${min}"
}

lcg_port() {
    local -i min=${1:-1024}
    local -i max=${2:-65535}
    lcg_integer "${min}" "${max}"
}
