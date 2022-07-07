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
    local modulus=${1:-${LCG_PARAMS_MODULUS:-65537}}
    local a=${2:-${LCG_PARAMS_A:-75}}
    local c=${3:-${LCG_PARAMS_C:-74}}
    local seed=${LCG_SEED:?}
    local x=$((a * seed + c))
    LCG_SEED=$((x - modulus * (x / modulus)))
    echo "${LCG_SEED}"
}

lcg_integer() {
    local min=${1:?}
    local max=${2:?}
    local seed
    seed=$(lcg)
    LCG_SEED=${seed}
    bc <<< "${seed} % (${max} - ${min}) + ${min}"
}

lcg_port() {
    local min=${1:-1024}
    local max=${2:-65535}
    lcg_integer "${min}" "${max}"
}


get_uid() {
    id -u
}


#' Check if TCP Port is Free
#'
#' Examples:
#' is_port_free 4001
#' is_free=$?
#'
#' Requirements:
#' * nc
is_port_free() {
    local port=${1:?}
    if nc -z 127.0.0.1 "$port"; then
        return 1
    fi
    return 0
}
