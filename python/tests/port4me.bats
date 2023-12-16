#!/usr/bin/env bats

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"
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
    run python -m port4me --user=alice
    assert_success
    assert_output "30845"
}

@test "python -m port4me with PORT4ME_USER=alice" {
    export PORT4ME_USER=alice
    run python -m port4me
    assert_success
    assert_output "30845"
}

@test "python -m port4me --user=bob" {
    run python -m port4me --user=bob
    assert_success
    assert_output "54242"
}

@test "python -m port4me --user=alice --tool=rstudio" {
    run python -m port4me --user=alice --tool=rstudio
    assert_success
    assert_output "22486"
}

@test "python -m port4me --user=alice with PORT4ME_TOOL=rstudio" {
    export PORT4ME_TOOL=rstudio
    run python -m port4me --user=alice
    assert_success
    assert_output "22486"
}

@test "python -m port4me --user=alice --exclude=30845,32310" {
    run python -m port4me --user=alice --exclude=30845,32310
    assert_success
    assert_output "19654"
}

@test "python -m port4me --user=alice with PORT4ME_EXCLUDE=30845,32310" {
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
    run python -m port4me --user=alice --include=2000-2123,4321,10000-10999
    assert_success
    assert_output "10451"
}

@test "python -m port4me --user=alice with PORT4ME_INCLUDE=2000-2123,4321,10000-10999" {
    export PORT4ME_INCLUDE=2000-2123,4321,10000-10999
    run python -m port4me --user=alice
    assert_success
    assert_output "10451"
}

@test "python -m port4me --user=alice --tool=jupyter-notebook" {
    run python -m port4me --user=alice --tool=jupyter-notebook
    assert_success
    assert_output "29525"
}

@test "python -m port4me --user=alice jupyter-notebook" {
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

@test "port4me --test=<BUSY_PORT> works" {
    ## Find an available TCP port
    port=$(python -m port4me --tool="port4me-tests")
    echo "Available TCP port: ${port}"

    ## Bind the TCP port temporarily
    timeout 5 nc -l "${port}" &  ## run in the background
    pid=$!
    echo "Background process (PID ${pid}) bound TCP port ${port}"

    ## Does 'port4me()' detect the port as non-available?
    ok=true
    if python -m port4me --test="${port}"; then
        ok=false
    fi
    echo "Result: ${ok}"

    ## Terminate background process again
    kill -SIGTERM "${pid}" || true
    wait "${pid}" || true

    ## Failed?
    ${ok} || fail "ERROR: port4me() failed to detect port as non-available"
}
