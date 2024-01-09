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
