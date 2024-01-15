#!/usr/bin/env bats

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"
    
    path="$(dirname "${BATS_TEST_FILENAME}")"

    # shellcheck source=../incl/port4me.bash
    source "${path}/../incl/port4me.bash"
}

@test "_p4m_string_to_uint" {
    hash=$(_p4m_string_to_uint "")
    assert_equal "${hash}" "0"

    hash=$(_p4m_string_to_uint "A")
    assert_equal "${hash}" "65"

    hash=$(_p4m_string_to_uint "alice,rstudio")
    assert_equal "${hash}" "3688618396"

    hash=$(_p4m_string_to_uint "port4me - get the same, personal, free TCP port over and over")
    assert_equal "${hash}" "1731535982"
}
