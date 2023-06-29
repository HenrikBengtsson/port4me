port4me_user <- function() {
  Sys.getenv("PORT4ME_USER", Sys.info()[["user"]])
}

port4me_tool <- function() {
  res <- Sys.getenv("PORT4ME_TOOL", NA_character_)
  if (is.na(res)) res <- NULL
  res
}

port4me_seed <- function(user = NULL, tool = NULL) {
  seed_str <- c(user, tool)
  seed_str <- seed_str[nzchar(seed_str)]
  if (length(seed_str) == 0) {
    stop("At least one of arguments 'user' and 'tool' must be non-empty")
  }
  seed_str <- paste(seed_str, collapse = ",")
  seed <- string_to_uint(seed_str)
  if (isTRUE(as.logical(Sys.getenv("PORT4ME_DEBUG", "false")))) {
    message(sprintf("seed_str='%s'", seed_str))
    message(sprintf("seed=%.0f", seed))
  }
  seed
}

## Source: https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc
## Last updated: 2022-10-24
ports_excluded_by_chrome <- function() {
  Sys.getenv("PORT4ME_EXCLUDE_UNSAFE_CHROME", "1,7,9,11,13,15,17,19,20,21,22,23,25,37,42,43,53,69,77,79,87,95,101,102,103,104,109,110,111,113,115,117,119,123,135,137,139,143,161,179,389,427,465,512,513,514,515,526,530,531,532,540,548,554,556,563,587,601,636,989,990,993,995,1719,1720,1723,2049,3659,4045,5060,5061,6000,6566,6665,6666,6667,6668,6669,6697,10080")
}

## Source: https://www-archive.mozilla.org/projects/netlib/portbanning#portlist
## Last updated: 2022-10-24
ports_excluded_by_firefox <- function() {
  Sys.getenv("PORT4ME_EXCLUDE_UNSAFE_FIREFOX", "1,7,9,11,13,15,17,19,20,21,22,23,25,37,42,43,53,77,79,87,95,101,102,103,104,109,110,111,113,115,117,119,123,135,139,143,179,389,465,512,513,514,515,526,530,531,532,540,556,563,587,601,636,993,995,2049,4045,6000")
}

parse_ports <- function(ports) {
  spec <- ports
  
  ports <- gsub("{chrome}", ports_excluded_by_chrome(), ports, fixed = TRUE)
  ports <- gsub("{firefox}", ports_excluded_by_firefox(), ports, fixed = TRUE)
  ports <- gsub("[ ]+", " ", ports, fixed = TRUE)
  ports <- unlist(strsplit(ports, split = "[, ]", fixed = FALSE))
  ports <- unique(ports)

  bad <- grep("^([[:digit:]]+|[[:digit:]]+-[[:digit:]]+)$", ports, invert = TRUE, value = TRUE)
  if (length(bad) > 0) {
    stop(sprintf("Syntax error in port specification: %s", spec))
  }
  ports <- lapply(ports, FUN = function(spec) {
    pattern <- "^([[:digit:]]+)-([[:digit:]]+)$"
    if (grepl(pattern, spec)) {
      from <- as.integer(gsub(pattern, "\\1", spec))
      to <- as.integer(gsub(pattern, "\\2", spec))
      from:to
    } else {
      as.integer(spec)
    }
  })
  ports <- unlist(ports, use.names = FALSE)
  stopifnot(!anyNA(ports))
  if (is.null(ports)) ports <- integer(0L)
  ports
}

port4me_prepend <- function() {
  ports <- NULL
  for (name in c("PORT4ME_PREPEND", "PORT4ME_PREPEND_SITE")) {
    arg <- Sys.getenv(name, "")
    ports <- c(ports, parse_ports(arg))
  }
  ports <- unique(ports)

  ports
}

port4me_exclude <- function() {
  defaults <- c(
    PORT4ME_EXCLUDE = "",
    PORT4ME_EXCLUDE_SITE = "",
    PORT4ME_EXCLUDE_UNSAFE = "{chrome},{firefox}"
  )

  ports <- NULL
  for (name in names(defaults)) {
    arg <- Sys.getenv(name, defaults[name])
    ports <- c(ports, parse_ports(arg))
  }
  ports <- unique(ports)
  
  ports
}

port4me_include <- function() {
  ports <- NULL
  for (name in c("PORT4ME_INCLUDE", "PORT4ME_INCLUDE_SITE")) {
    arg <- Sys.getenv(name, "")
    ports <- c(ports, parse_ports(arg))
  }
  ports <- unique(ports)
  
  ports
}

port4me_skip <- function() {
  skip <- as.integer(Sys.getenv("PORT4ME_SKIP", "0"))
  stopifnot(!is.na(skip))
  skip
}

port4me_list <- function() {
  list <- Sys.getenv("PORT4ME_LIST", NA_character_)
  if (is.na(list)) return(NULL)
  list <- as.integer(list)
  stopifnot(!is.na(list))
  list
}

port4me_test <- function() {
  test <- Sys.getenv("PORT4ME_TEST", NA_character_)
  if (is.na(test)) return(NULL)
  test <- as.integer(test)
  stopifnot(!is.na(test))
  test
}


#' Gets a Personalized TCP Port that can be Opened by the User
#'
#' @param tool (optional) The name of the software tool for which a port
#' should be generated.
#'
#' @param user (optional) The name of the user.
#' Defaults to `Sys.info()[["user"]]`.
#'
#' @param prepend (optional) An integer vector of ports to always consider.
#'
#' @param include (optional) An integer vector of possible ports to return.
#' Defaults to `1024:65535`.
#'
#' @param exclude (optional) An integer vector of ports to exclude.
#'
#' @param skip (optional) Number of non-excluded ports to skip.
#' Defaults to `0L`.
#'
#' @param list (optional) Number of ports to list.
#'
#' @param test (optional) A port to check whether it can be opened or not.
#'
#' @param max_tries Maximum number of ports checked, before giving up.
#' Defaults to `65535L`.
#'
#' @param must_work If TRUE, then an error is produced if no port could
#' be found.  If FALSE, then `-1` is returned.
#'
#' @return
#' A port, or a vector of ports.
#' If `test` is given, then TRUE is if the port can be opened, otherwise FALSE.
#'
#' @example incl/port4me.R
#'
#' @seealso
#' The default values of the arguments can be controlled via environment
#' variables.  See [port4me.settings] for details.
#'
#' @export
port4me <- function(tool = NULL, user = NULL, prepend = NULL, include = NULL, exclude = NULL, skip = NULL, list = NULL, test = NULL, max_tries = 65535L, must_work = TRUE) {
  if (is.null(tool)) tool <- port4me_tool()
  if (is.null(user)) user <- port4me_user()
  if (is.null(prepend)) prepend <- port4me_prepend()
  if (is.null(include)) include <- port4me_include()
  if (is.null(exclude)) exclude <- port4me_exclude()
  if (is.null(skip)) skip <- port4me_skip()
  if (is.null(list)) list <- port4me_list()
  if (is.null(test)) test <- port4me_test()
  
  stopifnot(is.null(tool) || is.character(tool), !anyNA(tool))
  stopifnot(length(user) == 1L, is.character(user), !is.na(user))
  if (!is.null(list)) {
    stopifnot(is.numeric(list), length(list) == 1L, !is.na(list), list >= 0)
  }
  stopifnot(length(max_tries) == 1L, is.numeric(max_tries), !is.na(max_tries), max_tries > 0, is.finite(max_tries))
  max_tries <- as.integer(max_tries)
  if (is.character(prepend)) prepend <- parse_ports(prepend)
  stopifnot(is.numeric(prepend), !anyNA(prepend), all(prepend > 0), all(prepend <= 65535))
  prepend <- as.integer(prepend)
  stopifnot(is.integer(prepend), !anyNA(prepend), all(prepend > 0), all(prepend <= 65535))
  if (is.character(exclude)) exclude <- parse_ports(exclude)
  stopifnot(is.numeric(exclude), !anyNA(exclude), all(exclude > 0), all(exclude <= 65535))
  if (is.character(include)) include <- parse_ports(include)
  stopifnot(is.numeric(include), !anyNA(include), all(include > 0), all(include <= 65535))
  stopifnot(length(skip) == 1L, is.numeric(skip), !is.na(skip), skip >= 0, is.finite(skip), skip < max_tries)
  skip <- as.integer(skip)
  if (!is.null(test)) {
    stopifnot(length(test) == 1)
    test <- as.integer(test)
    stopifnot(is.finite(test), test > 0, test <= 65535)
  }
  stopifnot(length(must_work) == 1L, is.logical(must_work), !is.na(must_work))

  lcg_set_seed(port4me_seed(user = user, tool = tool))

  if (!is.null(test)) {
    return(can_port_be_opened(test))
  }

  if (!is.null(list)) max_tries <- list + skip

  if (isTRUE(as.logical(Sys.getenv("PORT4ME_DEBUG", "false")))) {
    utils::str(list(
      include = include,
      exclude = exclude,
      prepend = prepend
    ))
  }

  ports <- integer(0)
  count <- 0L
  tries <- 0L
  while (tries <= max_tries) {
    if (length(prepend) > 0) {
      port <- prepend[1]
      prepend <- prepend[-1]
    } else {
      port <- lcg_port()
    }
    if (port %in% exclude) next
    if (length(include) > 0 && (! port %in% include)) next
    tries <- tries + 1L
    count <- count + 1L
    if (count <= skip) next
    if (is.null(list)) {
      if (can_port_be_opened(port)) return(port)
    } else {
      ports <- c(ports, port)
      if (length(ports) == list) return(ports)
    }
  }

  if (must_work) {
    stop(sprintf("Failed to find a free TCP port after %d attempts", max_tries))
  }

  -1L
}
class(port4me) <- c("cli_function", class(port4me))
