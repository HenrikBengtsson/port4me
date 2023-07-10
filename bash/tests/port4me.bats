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

@test "port4me --help" {
    run port4me --help
    assert_success
}

@test "port4me" {
    run port4me
    assert_success
}

@test "port4me --user=alice" {
    run port4me --user=alice
    assert_success
    assert_output "30845"
}

@test "port4me with PORT4ME_USER=alice" {
    export PORT4ME_USER=alice
    run port4me
    assert_success
    assert_output "30845"
}

@test "port4me --user=bob" {
    run port4me --user=bob
    assert_success
    assert_output "54242"
}

@test "port4me --user=alice --tool=rstudio" {
    run port4me --user=alice --tool=rstudio
    assert_success
    assert_output "22486"
}

@test "port4me --user=alice with PORT4ME_TOOL=rstudio" {
    export PORT4ME_TOOL=rstudio
    run port4me --user=alice
    assert_success
    assert_output "22486"
}

@test "port4me --user=alice --exclude=30845,32310" {
    run port4me --user=alice --exclude=30845,32310
    assert_success
    assert_output "19654"
}

@test "port4me --user=alice with PORT4ME_EXCLUDE=30845,32310" {
    export PORT4ME_EXCLUDE=30845,32310
    run port4me --user=alice
    assert_success
    assert_output "19654"
}

@test "port4me --user=alice --prepend=4321,11001 --list=5" {
    run port4me --user=alice --prepend=4321,11001 --list=5
    assert_success
    truth=(4321 11001 30845 19654 32310)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "port4me --user=alice --list=5 with PORT4ME_PREPEND=4321,11001" {
    export PORT4ME_PREPEND=4321,11001
    run port4me --user=alice --list=5
    assert_success
    truth=(4321 11001 30845 19654 32310)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "port4me --user=alice --include=2000-2123,4321,10000-10999" {
    run port4me --user=alice --include=2000-2123,4321,10000-10999
    assert_success
    assert_output "10451"
}

@test "port4me --user=alice with PORT4ME_INCLUDE=2000-2123,4321,10000-10999" {
    export PORT4ME_INCLUDE=2000-2123,4321,10000-10999
    run port4me --user=alice
    assert_success
    assert_output "10451"
}

@test "port4me --user=alice --tool=jupyter-notebook" {
    run port4me --user=alice --tool=jupyter-notebook
    assert_success
    assert_output "29525"
}

@test "port4me --user=alice --list=10" {
    run port4me --user=alice --list=10
    assert_success
    truth=(30845 19654 32310 63992 15273 31420 62779 55372 24143 41300)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "port4me --user=alice with PORT4ME_LIST=10" {
    export PORT4ME_LIST=10
    run port4me --user=alice
    assert_success
    truth=(30845 19654 32310 63992 15273 31420 62779 55372 24143 41300)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}
