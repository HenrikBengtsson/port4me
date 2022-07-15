port4me_user <- function() {
  Sys.getenv("PORT4ME_USER", Sys.info()[["user"]])
}

port4me_tool <- function() {
  res <- Sys.getenv("PORT4ME_TOOL", NA_character_)
  if (is.na(res)) res <- NULL
  res
}

port4me <- function(user = port4me_user(), tool = port4me_tool(), skip = as.integer(Sys.getenv("PORT4ME_SKIP", "0")), max_tries = 1000L, must_work = TRUE) {
  stopifnot(length(user) == 1L, is.character(user), !is.na(user))
  stopifnot(is.null(tool) || is.character(tool), !anyNA(tool))
  stopifnot(length(max_tries) == 1L, is.numeric(max_tries), !is.na(max_tries), max_tries > 0, is.finite(max_tries))
  max_tries <- as.integer(max_tries)
  stopifnot(length(skip) == 1L, is.numeric(skip), !is.na(skip), skip >= 0, is.finite(skip), skip < max_tries)
  skip <- as.integer(skip)
  stopifnot(length(must_work) == 1L, is.logical(must_work), !is.na(must_work))

  seed_str <- c(user, tool)
  seed_str <- seed_str[nzchar(seed_str)]
  if (length(seed_str) == 0) {
    stop("At least one of arguments 'user' and 'tool' must be non-empty")
  }
  seed_str <- paste(seed_str, collapse = ",")
  seed <- string_to_uint32(seed_str)
  lcg_set_seed(seed)
  
  for (kk in 1:max_tries) {
    port <- lcg_port()
    if (kk <= skip) next
    if (is_port_free(port)) return(port)
  }

  if (must_work) stop("Failed to find a free TCP port")

  -1L
}
