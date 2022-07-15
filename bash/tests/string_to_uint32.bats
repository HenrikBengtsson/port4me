#!/usr/bin/env bats

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"
    load "${BATS_FILE_HOME:?}/load.bash"
    source ../incl/java_hashCode.bash
}

@test "string_to_uint32" {
    hash=$(string_to_uint32 "")
    assert_equal "${hash}" "0"

    hash=$(string_to_uint32 "A")
    assert_equal "${hash}" "65"

    hash=$(string_to_uint32 "alice,rstudio")
    assert_equal "${hash}" "3688618396"

    hash=$(string_to_uint32 "port4me - get the same, personal, free TCP port over and over")
    assert_equal "${hash}" "1731535982"
}
