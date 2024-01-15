#!/usr/bin/env bats

# shellcheck disable=2030,2031

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"

    path="$(dirname "${BATS_TEST_FILENAME}")"

    # shellcheck source=incl/ports.sh
    source "${path}/incl/ports.sh"

    read -r -a cli_call <<< "${PORT4ME_CLI_CALL:?}"
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

@test "<CLI call> --user=alice --prepend=11001,4321 --list=5" {
    run "${cli_call[@]}" --user=alice --prepend=11001,4321 --list=5
    assert_success
    truth=(11001 4321 30845 19654 32310)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "<CLI call> --user=alice --list=5 with PORT4ME_PREPEND=11001,4321" {
    export PORT4ME_PREPEND=11001,4321
    run "${cli_call[@]}" --user=alice --list=5
    assert_success
    truth=(11001 4321 30845 19654 32310)
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

@test "<CLI call> --user=alice --include=1-1023 works" {
    local -i port
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run "${cli_call[@]}" --user=alice --include=1-1023
    assert_success
    assert_output --regexp "[[:digit:]]+"
    echo "Output:"
    printf "%s\n" "${lines[@]}"
    
    port=${lines[0]}
    [[ ${port} -ge 1 ]]
    [[ ${port} -le 1023 ]]
    assert_output "470"
}


@test "<CLI call> --user=alice --include=1-1023 --exclude=470,403 works" {
    local -i port
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run "${cli_call[@]}" --user=alice --include=1-1023 --exclude=470,403
    assert_success
    assert_output --regexp "[[:digit:]]+"
    echo "Output:"
    printf "%s\n" "${lines[@]}"
    
    port=${lines[0]}
    [[ ${port} -ge 1 ]]
    [[ ${port} -le 1023 ]]
    assert_output "859"
}


@test "<CLI call> --user=alice --prepend=2000-2009 --include=1-1023 returns 2000" {
    local -i port
    export _PORT4ME_CHECK_AVAILABLE_PORTS_=any
    run "${cli_call[@]}" --user=alice --prepend=2000-2009 --include=1-1023
    assert_success
    assert_output "2000"
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

@test "<CLI call> --user=alice --skip=2" {
    run "${cli_call[@]}" --user=alice --skip=2
    assert_success
    assert_output "32310"
}

@test "<CLI call> --user=alice with PORT4ME_SKIP=2" {
    export PORT4ME_SKIP=2
    run "${cli_call[@]}" --user=alice
    assert_success
    assert_output "32310"
}

@test "<CLI call> --user=alice --list=3 --skip=2" {
    run "${cli_call[@]}" --user=alice --list=3 --skip=2
    assert_success
    truth=(32310 63992 15273)
    [[ "${lines[*]}" == "${truth[*]}" ]]
}

@test "_PORT4ME_CHECK_AVAILABLE_PORTS_='any' --test=80 works" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_="any"
    run "${cli_call[@]}" --test=80
    assert_success
}

@test "_PORT4ME_CHECK_AVAILABLE_PORTS_='any' --test=0 fails" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_="any"
    run "${cli_call[@]}" --test=0
    assert_failure
}

@test "_PORT4ME_CHECK_AVAILABLE_PORTS_='any' --test=65536 fails" {
    export _PORT4ME_CHECK_AVAILABLE_PORTS_="any"
    run "${cli_call[@]}" --test=65536
    assert_failure
}

@test "<CLI call> --test=80 fail" {
    [[ $(uname -s) == "Linux" ]] || skip "Privileged ports are only blocked on Linux: $(uname -s)"
    
    unset _PORT4ME_CHECK_AVAILABLE_PORTS
    run "${cli_call[@]}" --test=80
    assert_failure
}

@test "<CLI call> --test=<BUSY_PORT> works" {
    unset _PORT4ME_CHECK_AVAILABLE_PORTS_
    assert_busy_port "${cli_call[@]}"
}


## -------------------------------------------------------------
## Errors
## -------------------------------------------------------------
@test "<CLI call> --test=65536 gives error" {
    run "${cli_call[@]}" --test=65536
    assert_failure
    assert_output --regexp "(error|ERROR|Error)"
}

@test "<CLI call> --test=foo gives error" {
    run "${cli_call[@]}" --test=foo
    assert_failure
    assert_output --regexp "(error|ERROR|Error)"
}

@test "<CLI call> --list=-1 gives error" {
    run "${cli_call[@]}" --list=-1
    assert_failure
    assert_output --regexp "(error|ERROR|Error)"
}

@test "<CLI call> --list=foo gives error" {
    run "${cli_call[@]}" --list=foo
    assert_failure
    assert_output --regexp "(error|ERROR|Error)"
}

@test "<CLI call> --skip=-1 gives error" {
    run "${cli_call[@]}" --skip=-1
    assert_failure
    assert_output --regexp "(error|ERROR|Error)"
}

@test "<CLI call> --skip=foo gives error" {
    run "${cli_call[@]}" --skip=foo
    assert_failure
    assert_output --regexp "(error|ERROR|Error)"
}

@test "<CLI call> --exclude=foo gives error" {
    run "${cli_call[@]}" --exclude=foo
    assert_failure
    assert_output --regexp "(error|ERROR|Error)"
}

@test "<CLI call> --include=foo gives error" {
    run "${cli_call[@]}" --include=foo
    assert_failure
    assert_output --regexp "(error|ERROR|Error)"
}

@test "<CLI call> --prepend=foo gives error" {
    run "${cli_call[@]}" --prepend=foo
    assert_failure
    assert_output --regexp "(error|ERROR|Error)"
}

