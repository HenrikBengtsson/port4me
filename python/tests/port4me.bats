#!/usr/bin/env bats

# shellcheck disable=2030,2031

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"

    path="$(dirname "${BATS_TEST_FILENAME}")"

    # shellcheck source=incl/ports.sh
    source "${path}/incl/ports.sh"
}

@test "python -m port4me --version" {
    run python -m port4me --version
    assert_success
}

@test "python -m port4me --help" {
    run python -m port4me --help
    assert_success
}

@test "python -m port4me" {
    run python -m port4me
    assert_success
}

@test "python -m port4me --user=alice" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run python -m port4me --user=alice
    assert_success
    assert_output "30845"
}

@test "python -m port4me with PORT4ME_USER=alice" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    export PORT4ME_USER=alice
    run python -m port4me
    assert_success
    assert_output "30845"
}

@test "python -m port4me --user=bob" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run python -m port4me --user=bob
    assert_success
    assert_output "54242"
}

@test "python -m port4me --user=alice --tool=rstudio" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run python -m port4me --user=alice --tool=rstudio
    assert_success
    assert_output "22486"
}

@test "python -m port4me --user=alice with PORT4ME_TOOL=rstudio" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    export PORT4ME_TOOL=rstudio
    run python -m port4me --user=alice
    assert_success
    assert_output "22486"
}

@test "python -m port4me --user=alice --exclude=30845,32310" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run python -m port4me --user=alice --exclude=30845,32310
    assert_success
    assert_output "19654"
}

@test "python -m port4me --user=alice with PORT4ME_EXCLUDE=30845,32310" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    export PORT4ME_EXCLUDE=30845,32310
    run python -m port4me --user=alice
    assert_success
    assert_output "19654"
}

@test "python -m port4me --user=alice --prepend=4321,11001 --list=5" {
    run python -m port4me --user=alice --prepend=4321,11001 --list=5
    assert_success
    truth=(4321 11001 30845 19654 32310)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "python -m port4me --user=alice --list=5 with PORT4ME_PREPEND=4321,11001" {
    export PORT4ME_PREPEND=4321,11001
    run python -m port4me --user=alice --list=5
    assert_success
    truth=(4321 11001 30845 19654 32310)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "python -m port4me --user=alice --include=2000-2123,4321,10000-10999" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run python -m port4me --user=alice --include=2000-2123,4321,10000-10999
    assert_success
    assert_output "10451"
}

@test "python -m port4me --user=alice with PORT4ME_INCLUDE=2000-2123,4321,10000-10999" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    export PORT4ME_INCLUDE=2000-2123,4321,10000-10999
    run python -m port4me --user=alice
    assert_success
    assert_output "10451"
}

@test "python -m port4me --user=alice --tool=jupyter-notebook" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run python -m port4me --user=alice --tool=jupyter-notebook
    assert_success
    assert_output "29525"
}

@test "python -m port4me --user=alice jupyter-notebook" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run python -m port4me --user=alice jupyter-notebook
    assert_success
    assert_output "29525"
}

@test "python -m port4me --user=alice --list=10" {
    run python -m port4me --user=alice --list=10
    assert_success
    truth=(30845 19654 32310 63992 15273 31420 62779 55372 24143 41300)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "python -m port4me --user=alice with PORT4ME_LIST=10" {
    export PORT4ME_LIST=10
    run python -m port4me --user=alice
    assert_success
    truth=(30845 19654 32310 63992 15273 31420 62779 55372 24143 41300)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "python -m port4me --test=<BUSY_PORT> works" {
    assert_busy_port python -m port4me
}

@test "_PORT4ME_CHECK_AVAILABLE_PORTS_='any' works" {
    _PORT4ME_CHECK_AVAILABLE_PORTS_="any"  Rscript -e port4me::port4me --args --test=80
}
