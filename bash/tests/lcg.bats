#!/usr/bin/env bats

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"
    source ../incl/lcg.bash
}

@test "lcg_set_params" {
    run lcg_set_params
    assert_success
    
    run lcg_set_params 1 2 3
    assert_success

    run lcg_set_params 0 2 3
    assert_failure
    assert_output --partial "ERROR"

    run lcg_set_params 1 0 3
    assert_failure
    assert_output --partial "ERROR"

    run lcg_set_params 1 2 0
    assert_failure
    assert_output --partial "ERROR"
}

@test "lcg" {
    lcg_set_params
    lcg_set_seed 42
    
    run lcg
    assert_success
    assert_output "3224"
    
    run lcg 65537 75 74
    assert_success
    assert_output "3224"

    run lcg 0 75 74
    assert_failure
    assert_output --partial "'modulus' must be positive"

    run lcg 65537 0 74
    assert_failure
    assert_output --partial "'a' must be positive"

    run lcg 65537 75 0
    assert_failure
    assert_output --partial "'c' must be positive"
}

@test "lcg with initial seed = m - (a-c) (special case)" {
    lcg_set_params
    lcg_set_seed 65536
    
    run lcg
    assert_success
    assert_output "74"
}


@test "lcg_set_seed" {
    run lcg_set_seed 42
    assert_success

    run lcg_set_seed -1
    assert_failure
    assert_output --partial "ERROR"

    run lcg_set_seed
    assert_failure
    assert_output --partial "parameter null or not set"
}

@test "lcg_get_seed" {
    lcg_set_seed 1
    run lcg_get_seed
    assert_success
    assert_output "1"

    lcg_set_seed 42
    run lcg_get_seed
    assert_success
    assert_output "42"
}


@test "lcg_integer" {
    lcg_set_params
    
    lcg_set_seed 42
    run lcg_integer 0 100
    assert_success
    assert_output "93"

    lcg_set_seed 42
    run lcg_integer 0 100
    assert_success
    assert_output "93"

    lcg_set_seed 42   
    run lcg_integer 0 100000
    assert_success
    assert_output "3224"

    lcg_set_seed 42
    run lcg_integer 0 10000000
    assert_success
    assert_output "3224"

    run lcg_integer
    assert_failure
    assert_output --partial "parameter null or not set"

    run lcg_integer 0
    assert_failure
    assert_output --partial "parameter null or not set"
}


lcg_port_times() {
    local -i n=${1:?}
    local -i res=-1
    while ((n > 0)); do
        lcg_port > /dev/null
        res=${LCG_SEED:?}
        n=$((n - 1))
    done
    echo $res
}

@test "lcg_port" {
    lcg_set_params
    
    lcg_set_seed 42
    run lcg_port
    assert_success
    assert_output "3224"

    lcg_set_seed 42
    run lcg_port
    assert_success
    assert_output "3224"

    lcg_set_seed 42
    run lcg_port_times 0
    assert_success
    assert_output "-1"

    lcg_set_seed 42
    run lcg_port_times 1
    assert_success
    assert_output "3224"

    lcg_set_seed 42
    run lcg_port_times 2
    assert_success
    assert_output "45263"

    lcg_set_seed 42
    run lcg_port_times 2
    assert_success
    assert_output "45263"

    lcg_set_seed 42
    run lcg_port_times 10
    assert_success
    assert_output "16281"
}
