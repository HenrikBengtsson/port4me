#!/usr/bin/env bash
#' Bash completion function for 'port4me' (internal)
#'
#' @usage
#' PORT4ME_HOME=$(dirname "$(dirname "$(command -v port4me)")")
#' source "${PORT4ME_HOME}/completions/port4me-completion.bash"
#'
#' @param `COMP_WORDS`: Array of words.
#' @param `COMP_CWORD`: Current cursor position index into `COMP_WORDS`.
#'
#' @return
#' `COMPREPLY`: Array of possible completions.
#'
#' @references
#' Section 'Programmable Completion' in `man bash'.
#'
#' References
_port4me_completion() {
    # The current word being completed
    local curr=${COMP_WORDS[COMP_CWORD]}

    case "${curr}" in
        --d*|--h*|--v*)
             mapfile -t COMPREPLY < <(compgen -W "--debug --help --version" -- "${curr}")
             return 0
             ;;
        *)
             mapfile -t COMPREPLY < <(compgen -W "--exclude= --include= --list= --prepend= --test= --tool= --user=" -- "${curr}")
             compopt -o nospace
             return 0
             ;;
    esac
}

# Associate function to 'port4me' executable
complete -F _port4me_completion port4me
