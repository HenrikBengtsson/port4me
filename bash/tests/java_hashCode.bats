#!/usr/bin/env bats

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"
    load "${BATS_FILE_HOME:?}/load.bash"
    source ../incl/java_hashCode.bash
}

@test "java_hashCode" {
    hash=$(java_hashCode "")
    assert_equal "${hash}" "0"

    hash=$(java_hashCode "A")
    assert_equal "${hash}" "65"

    hash=$(java_hashCode "alice,rstudio")
    assert_equal "${hash}" "-606348900"

    hash=$(java_hashCode "port4me - get the same, personal, free TCP port over and over")
    assert_equal "${hash}" "1731535982"
}
