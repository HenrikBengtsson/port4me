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

port4me_include <- function() {
  include <- NULL

  for (name in c("PORT4ME_INCLUDE", "PORT4ME_INCLUDE_SITE")) {
    arg <- Sys.getenv(name, "")
    ports <- parse_ports(arg)
    include <- c(include, ports)
  }
  include <- unique(include)
  
  include
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

port4me <- function(user = port4me_user(), tool = port4me_tool(), include = port4me_include(), exclude = port4me_exclude(), skip = port4me_skip(), list = NULL, test = NULL, max_tries = 1000L, must_work = TRUE) {
  stopifnot(length(user) == 1L, is.character(user), !is.na(user))
  stopifnot(is.null(tool) || is.character(tool), !anyNA(tool))
  if (!is.null(list)) {
    stopifnot(is.numeric(list), length(list) == 1L, !is.na(list), list >= 0)
  }
  stopifnot(length(max_tries) == 1L, is.numeric(max_tries), !is.na(max_tries), max_tries > 0, is.finite(max_tries))
  max_tries <- as.integer(max_tries)
  if (is.character(include)) include <- parse_ports(include)
  stopifnot(is.numeric(include), !anyNA(include), all(include > 0), all(include <= 65535))
  if (is.character(exclude)) exclude <- parse_ports(exclude)
  stopifnot(is.numeric(exclude), !anyNA(exclude), all(exclude > 0), all(exclude <= 65535))
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

  ports <- integer(0)
  count <- 0L
  while (count <= max_tries) {
    if (length(include) > 0) {
      port <- include[1]
      include <- include[-1]
    } else {
      port <- lcg_port()
    }
    if (port %in% exclude) next
    count <- count + 1L
    if (count <= skip) next
    if (is.null(list)) {
      if (can_port_be_opened(port)) return(port)
    } else {
      ports <- c(ports, port)
      if (length(ports) == list) return(ports)
    }
  }

  if (must_work) stop("Failed to find a free TCP port")

  -1L
}
