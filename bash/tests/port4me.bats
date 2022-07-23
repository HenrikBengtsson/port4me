#!/usr/bin/env bats

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"
    export PATH=..:$PATH
}

@test "port4me --version" {
    run port4me --version
    assert_success
}

@test "port4me" {
    run port4me
    assert_success
}

@test "port4me --user=alice --tool=rstudio" {
    run port4me --user=alice --tool=rstudio
    assert_success
    assert_output "23510"
}

@test "port4me --list=10" {
    run port4me --user=alice --list=10
    assert_success
    truth=(31869 20678 33334 65016 16297 32444 63803 56396 25167 42324)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}
