#!/usr/bin/env bats

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"
    source ../incl/string_to_uint.bash
}

@test "string_to_uint" {
    hash=$(string_to_uint "")
    assert_equal "${hash}" "0"

    hash=$(string_to_uint "A")
    assert_equal "${hash}" "65"

    hash=$(string_to_uint "alice,rstudio")
    assert_equal "${hash}" "3688618396"

    hash=$(string_to_uint "port4me - get the same, personal, free TCP port over and over")
    assert_equal "${hash}" "1731535982"
}
