#!/usr/bin/env bats

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"
    source ../incl/lcg.bash
}

@test "lcg" {
    LCG_SEED=42
    
    run lcg
    assert_success
    assert_output "3224"
}

@test "lcg with initial seed = m - (a-c) (special case)" {
    LCG_SEED=65536
    
    run lcg
    assert_success
    assert_output "74"
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
    LCG_SEED=42
    run lcg_port
    assert_success
    assert_output "3224"

    LCG_SEED=42
    run lcg_port
    assert_success
    assert_output "3224"

    LCG_SEED=42
    run lcg_port_times 0
    assert_success
    assert_output "-1"

    LCG_SEED=42
    run lcg_port_times 1
    assert_success
    assert_output "3224"

    LCG_SEED=42
    run lcg_port_times 2
    assert_success
    assert_output "45263"

    LCG_SEED=42
    run lcg_port_times 2
    assert_success
    assert_output "45263"

    LCG_SEED=42
    run lcg_port_times 10
    assert_success
    assert_output "16281"
}
