#! /usr/bin/env bash

#' Find a free TCP port and bind to it for a moment
#'
#' @param ... port4me command with options
#'
#' @return
#' Returns a string of format `"{port}:{pid}"`, where `{pid}` is the
#' process ID of the background process binding the port `{port}`.
bind_a_port() {
    local -a cmd
    local -i port
    local -i pid
    local -i kk
    local -i max_tries
    local duration
    local delay
    local tf
    local timeout

    cmd=("$@")    
    >&2 echo "cmd: [n=${#cmd[@]}] ${cmd[*]}"

    ## Number of seconds that the port should be bound
    duration=5.0

    ## Max number of attempts and delay (in seconds) between attempts
    max_tries=5
    delay=2.0

    ## If 'timeout' isn't available, try 'gtimeout'
    timeout="timeout"
    if ! command -v "${timeout}" > /dev/null; then
        timeout="gtimeout"
        if ! command -v "${timeout}" > /dev/null; then
            >&2 echo "bind_a_port(): Neither 'timeout' nor 'gtimeout' exists, but are required"
            port=0
            pid=0
            echo "${port}"
            echo "${pid}"
            return 1
        fi
    fi
    
    ## Find an available TCP port and bind it (try for 10 seconds)
    tf=$(mktemp)
    for kk in $(seq "${max_tries}"); do
        ## (a) Find an available TCP port
        port=$(PORT4ME_SKIP="$((kk - 1))" "${cmd[@]}" --tool="port4me-tests")
        >&2 echo "Trying with TCP port: ${port}"

        ## (b) Bind the TCP port temporarily
        {
            echo "begin"
            "${timeout}" "${duration}" nc -l "${port}"
            echo "end"
        } > "${tf}" &  ## run in the background
        pid=$!

        ## (c) Give background process some time to start
        sleep 0.2

        ## (d) Success?
        ## We expect to see a 'begin', but not an 'end' here
        if grep -q -F "begin" < "${tf}"; then
            if ! grep -q -F "end" < "${tf}"; then
                break
            fi
        fi

        >&2 echo "Failed to bind TCP port ${port}. Retrying in 2.0 seconds ..."

        ## (e) Retry
        kill -SIGTERM "${pid}"
        wait "${pid}"
        pid=0
        if [[ ${kk} -lt 5 ]]; then
            sleep "${delay}"
        fi
    done
    rm "${tf}"

    if [[ ${pid} -eq 0 ]]; then
        >&2 echo "Failed to bind TCP port ${port}"
        port=0
    else
        >&2 echo "Background process (PID ${pid}) bound TCP port ${port}"
    fi
    
    echo "${port}"
    echo "${pid}"
}


#' Assert that port4me detects that a bound TCP port is busy
#'
#' @param ... port4me command with options
#'
#' @return
#' Returns 0 if success, otherwise an error is thrown.
assert_busy_port() {
    local -i port
    local -i pid
    local -a cmd
    local -a res

    cmd=("$@")    
    >&2 echo "cmd: [n=${#cmd[@]}] ${cmd[*]}"

    ## Find an available TCP port and bind it (try for 10 seconds)
    ## NOTE: We don't use 'mapfile' here, because that requires
    ## Bash (>= 4.0), but macOS only has Bash 3.
    res=$(bind_a_port "${cmd[@]}")
    port=${res//$'\n'*}
    pid=${res/*$'\n'}
    [[ ${pid} -gt 0 ]] || fail "ERROR: port4me failed to bind a TCP port"    
    >&2 echo "Background process (PID ${pid}) bound TCP port ${port}"

    ## Does 'port4me' detect the port as non-available?
    ok=true
    if "${cmd[@]}" --test="${port}"; then
        ok=false
    fi
    >&2 echo "Result: ${ok}"

    ## Terminate background process again
    kill -SIGTERM "${pid}" 2> /dev/null || true
    wait "${pid}" 2> /dev/null || true

    ## Failed?
    ${ok} || fail "ERROR: port4me failed to detect port as non-available"

    return 0
}
