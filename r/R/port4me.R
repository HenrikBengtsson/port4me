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
  ports <- paste(ports, collapse = ",")
  ports <- gsub(" ", "", ports, fixed = TRUE)
  ports <- unlist(strsplit(ports, split = ","))
  bad <- grep("^[[:digit:]]+$", ports, invert = TRUE, value = TRUE)
  if (length(bad) > 0) {
    stop(sprintf("Syntax error in 'exclude' argument: %s", arg))
  }
  ports <- as.integer(ports)
  stopifnot(!anyNA(ports))
  ports
}

port4me_exclude <- function() {
  exclude <- NULL

  for (name in c("PORT4ME_EXCLUDE", "PORT4ME_EXCLUDE_SITE")) {
    arg <- Sys.getenv(name, "")
    ports <- parse_ports(arg)
    exclude <- c(exclude, ports)
  }
  exclude <- unique(exclude)
  
  exclude
}

port4me_skip <- function() {
  skip <- as.integer(Sys.getenv("PORT4ME_SKIP", "0"))
  stopifnot(!is.na(skip))
  skip
}

port4me <- function(user = port4me_user(), tool = port4me_tool(), exclude = port4me_exclude(), skip = port4me_skip(), list = NULL, max_tries = 1000L, must_work = TRUE) {
  stopifnot(length(user) == 1L, is.character(user), !is.na(user))
  stopifnot(is.null(tool) || is.character(tool), !anyNA(tool))
  if (!is.null(list)) {
    stopifnot(is.numeric(list), length(list) == 1L, !is.na(list), list >= 0)
  }
  stopifnot(length(max_tries) == 1L, is.numeric(max_tries), !is.na(max_tries), max_tries > 0, is.finite(max_tries))
  max_tries <- as.integer(max_tries)
  if (is.character(exclude)) exclude <- parse_ports(exclude)
  stopifnot(is.numeric(exclude), !anyNA(exclude), all(exclude > 0), all(exclude <= 65535))
  stopifnot(length(skip) == 1L, is.numeric(skip), !is.na(skip), skip >= 0, is.finite(skip), skip < max_tries)
  skip <- as.integer(skip)
  stopifnot(length(must_work) == 1L, is.logical(must_work), !is.na(must_work))

  lcg_set_seed(port4me_seed(user = user, tool = tool))

  if (!is.null(list)) {
    return(vapply(seq_len(list), FUN.VALUE = NA_integer_,
                    FUN = function(kk) lcg_port()))
  }

  count <- 0L
  while (count <= max_tries) {
    port <- lcg_port()
    if (port %in% exclude) next
    count <- count + 1L
    if (count <= skip) next
    if (is_port_free(port)) return(port)
  }

  if (must_work) stop("Failed to find a free TCP port")

  -1L
}
