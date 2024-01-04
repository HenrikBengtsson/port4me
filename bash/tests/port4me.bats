#!/usr/bin/env bats

# shellcheck disable=2030,2031

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"

    path="$(dirname "${BATS_TEST_FILENAME}")"

    # shellcheck source=incl/ports.sh
    source "${path}/incl/ports.sh"

    cli_call=(port4me)
}

@test "<CLI call> --version" {
    run "${cli_call[@]}" --version
    assert_success
}

@test "<CLI call> --help" {
    run "${cli_call[@]}" --help
    assert_success
}

@test "<CLI call> (without arguments)" {
    run "${cli_call[@]}"
    assert_success
}

@test "<CLI call> --user=alice" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run "${cli_call[@]}" --user=alice
    assert_success
    assert_output "30845"
}

@test "<CLI call> with PORT4ME_USER=alice (without arguments)" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    export PORT4ME_USER=alice
    run "${cli_call[@]}"
    assert_success
    assert_output "30845"
}

@test "<CLI call> --user=bob" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run "${cli_call[@]}" --user=bob
    assert_success
    assert_output "54242"
}

@test "<CLI call> --user=alice --tool=rstudio" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run "${cli_call[@]}" --user=alice --tool=rstudio
    assert_success
    assert_output "22486"
}

@test "<CLI call> --user=alice with PORT4ME_TOOL=rstudio" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    export PORT4ME_TOOL=rstudio
    run "${cli_call[@]}" --user=alice
    assert_success
    assert_output "22486"
}

@test "<CLI call> --user=alice --exclude=30845,32310" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run "${cli_call[@]}" --user=alice --exclude=30845,32310
    assert_success
    assert_output "19654"
}

@test "<CLI call> --user=alice with PORT4ME_EXCLUDE=30845,32310" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    export PORT4ME_EXCLUDE=30845,32310
    run "${cli_call[@]}" --user=alice
    assert_success
    assert_output "19654"
}

@test "<CLI call> --user=alice --prepend=4321,11001 --list=5" {
    run "${cli_call[@]}" --user=alice --prepend=4321,11001 --list=5
    assert_success
    truth=(4321 11001 30845 19654 32310)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "<CLI call> --user=alice --list=5 with PORT4ME_PREPEND=4321,11001" {
    export PORT4ME_PREPEND=4321,11001
    run "${cli_call[@]}" --user=alice --list=5
    assert_success
    truth=(4321 11001 30845 19654 32310)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "<CLI call> --user=alice --include=2000-2123,4321,10000-10999" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run "${cli_call[@]}" --user=alice --include=2000-2123,4321,10000-10999
    assert_success
    assert_output "10451"
}

@test "<CLI call> --user=alice with PORT4ME_INCLUDE=2000-2123,4321,10000-10999" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    export PORT4ME_INCLUDE=2000-2123,4321,10000-10999
    run "${cli_call[@]}" --user=alice
    assert_success
    assert_output "10451"
}

@test "<CLI call> --user=alice --tool=jupyter-notebook" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run "${cli_call[@]}" --user=alice --tool=jupyter-notebook
    assert_success
    assert_output "29525"
}

@test "<CLI call> --user=alice jupyter-notebook" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run "${cli_call[@]}" --user=alice jupyter-notebook
    assert_success
    assert_output "29525"
}

@test "<CLI call> --user=alice --list=10" {
    run "${cli_call[@]}" --user=alice --list=10
    assert_success
    truth=(30845 19654 32310 63992 15273 31420 62779 55372 24143 41300)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "<CLI call> --user=alice with PORT4ME_LIST=10" {
    export PORT4ME_LIST=10
    run "${cli_call[@]}" --user=alice
    assert_success
    truth=(30845 19654 32310 63992 15273 31420 62779 55372 24143 41300)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "_PORT4ME_CHECK_AVAILABLE_PORTS_='any' works" {
    _PORT4ME_CHECK_AVAILABLE_PORTS_="any" "${cli_call[@]}" --test=80
}

@test "<CLI call> --test=80 fail" {
    run "${cli_call[@]}" --test=80
    assert_failure
}

@test "<CLI call> --test=<BUSY_PORT> works" {
    assert_busy_port "${cli_call[@]}"
}

@test "port4me --test=<BUSY_PORT> works using 'ncat'" {
    command -v "ncat" > /dev/null || skip "Test requires that 'ncat' is availble"
    PORT4ME_PORT_COMMAND="ncat" assert_busy_port "${cli_call[@]}"
}

@test "port4me --test=<BUSY_PORT> works using 'netstat'" {
    command -v "netstat" > /dev/null || skip "Test requires that 'netstat' is availble"
    PORT4ME_PORT_COMMAND="netstat" assert_busy_port "${cli_call[@]}"
}

@test "port4me --test=<BUSY_PORT> works using 'ss'" {
    command -v "ss" > /dev/null || skip "Test requires that 'ss' is availble"
    PORT4ME_PORT_COMMAND="ss" assert_busy_port "${cli_call[@]}"
}
