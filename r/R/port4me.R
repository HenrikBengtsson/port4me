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

parse_ports <- function(ports) {
  spec <- ports
  ports <- paste(ports, collapse = ",")
  ports <- gsub(" ", "", ports, fixed = TRUE)
  ports <- unlist(strsplit(ports, split = ","))
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
  ports <- NULL

  for (name in c("PORT4ME_EXCLUDE", "PORT4ME_EXCLUDE_SITE")) {
    arg <- Sys.getenv(name, "")
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


#' Gets a personalized TCP port that can be opened
#'
#' @param user (optional) The name of the user.
#' Defaults to `Sys.info()[["user"]]`.
#'
#' @param tool (optional) The name of the software tool for which a port
#' should be generated.
#'
#' @param prepend (optional) An integer vector of ports to always consider.
#'
#' @param include (optional) An integer vector of possible ports to return.
#' Defaults to `1024::65535`.
#'
#' @param exclude (optional) An integer vector of ports to exclude.
#'
#' @param skip (optional) Number of non-excluded ports to skip.
#'
#' @param list (optional) Number of ports to list.
#'
#' @param test (optional) A port to check whether it can be opened or not.
#'
#' @param max_tries Maximum number of ports checked, before giving up.
#'
#' @param must_work If TRUE, then an error is produced if no port could
#' be found.  If FALSE, then `-1` is returned.
#'
#' @return
#' An port or a vector of ports.
#' If `test` is given, then TRUE is if the port can be opened, otherwise FALSE.
#'
#' @example incl/port4me.R
#'
#' @export
port4me <- function(user = port4me_user(), tool = port4me_tool(), prepend = port4me_prepend(), include = port4me_include(), exclude = port4me_exclude(), skip = port4me_skip(), list = NULL, test = NULL, max_tries = 65535L, must_work = TRUE) {
  stopifnot(length(user) == 1L, is.character(user), !is.na(user))
  stopifnot(is.null(tool) || is.character(tool), !anyNA(tool))
  if (!is.null(list)) {
    stopifnot(is.numeric(list), length(list) == 1L, !is.na(list), list >= 0)
  }
  stopifnot(length(max_tries) == 1L, is.numeric(max_tries), !is.na(max_tries), max_tries > 0, is.finite(max_tries))
  max_tries <- as.integer(max_tries)
  if (is.character(prepend)) prepend <- parse_ports(prepend)
  stopifnot(is.numeric(prepend), !anyNA(prepend), all(prepend > 0), all(prepend <= 65535))
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
