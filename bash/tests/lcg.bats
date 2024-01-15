#!/usr/bin/env bats

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"
    
    path="$(dirname "${BATS_TEST_FILENAME}")"

    # shellcheck source=../incl/port4me.bash
    source "${path}/../incl/port4me.bash"
}

@test "lcg" {
    LCG_SEED=42 run _p4m_lcg
    assert_success
    assert_output "3224"
}

@test "lcg with initial seed = m - (a-c) (special case)" {
    LCG_SEED=65536 run _p4m_lcg
    assert_success
    assert_output "74"
}

lcg_port_times() {
    local -i n=${1:?}
    local -i port=-1
    while ((n > 0)); do
        _p4m_lcg > /dev/null
        port=${LCG_SEED:?}
        if (( port < 1024 || port > 65535 )); then
            continue
        fi
        n=$((n - 1))
    done
    echo $port
}

@test "lcg_port" {
    LCG_SEED=42 run lcg_port_times 0
    assert_success
    assert_output "-1"

    LCG_SEED=42 run lcg_port_times 1
    assert_success
    assert_output "3224"

    LCG_SEED=42 run lcg_port_times 2
    assert_success
    assert_output "45263"

    LCG_SEED=42 run lcg_port_times 2
    assert_success
    assert_output "45263"

    LCG_SEED=42 run lcg_port_times 10
    assert_success
    assert_output "16281"
}
