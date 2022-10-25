#' Settings Used by the 'port4me' Package
#'
#' Below are the environment variables that are used by the \pkg{port4me}
#' package and packages enhancing it.\cr
#' \cr
#' _WARNING: Note that the names and the default values of these settings
#'  may change in future versions of the package.  Please use with care
#'  until further notice._
#'
#' \describe{
#'  \item{`PORT4ME_EXCLUDE`:}{
#'   Controls the default value for argument `exclude` of [port4me()].
#'   Ports and port sequences should be separated by commas.
#'   Port sequences should be specified as a start and end port separated
#'   by a hyphen.
#'   Example: `PORT4ME_EXCLUDE=4444,5000-5999,8080`.
#'   (Default: empty)
#'  }
#'
#'  \item{`PORT4ME_INCLUDE`:}{
#'   Controls the default value for argument `include` of [port4me()].
#'   The format should be the same as for `PORT4ME_INCLUDE`.
#'   (Default: empty)
#'  }
#'
#'  \item{`PORT4ME_PREPEND`:}{
#'   Controls the default value for argument `prepend` of [port4me()].
#'   The format should be the same as for `PORT4ME_INCLUDE`.
#'   (Default: empty)
#'  }
#'
#'  \item{`PORT4ME_SKIP`:}{
#'   Controls the default value for argument `skip` of [port4me()].
#'   (Default: `0`)
#'  }
#'
#'  \item{`PORT4ME_TOOL`:}{
#'   Controls the default value for argument `tool` of [port4me()].
#'   (Default: empty)
#'  }
#'
#'  \item{`PORT4ME_USER`:}{
#'   Controls the default value for argument `user` of [port4me()].
#'   (Default: `Sys.info()[["user"]])`)
#'  }
#' }
#'
#'
#' @section Site-wide and built-in settings:
#'
#' \describe{
#'  \item{`PORT4ME_EXCLUDE_SITE`, `PORT4ME_INCLUDE_SITE`,
#'   `PORT4ME_PREPEND_SITE`:}{
#'   Additional sets of ports to be excluded, included, and prepended.
#'   These are typically set for all users ("site wide") by a
#'   systems administrator or similar.
#'   (Default: empty)
#'  }
#'
#'  \item{`PORT4ME_EXCLUDE_UNSAFE`:}{
#'   Additional sets of ports to be excluded that are considered unsafe
#'   to open in a web browser.
#'   Special token `"{chrome}"` expands to the value of environment
#'   variable `PORT4ME_EXCLUDE_UNSAFE_CHROME`.
#'   Special token `"{firefox}"` expands to the value of environment
#'   variable `PORT4ME_EXCLUDE_UNSAFE_FIREFOX`.
#'   The default is to exclude the ports that Chrome and Firefox blocks.
#'   (Default: `"{chrome},{firefox}"`)
#'  }
#'
#'  \item{`PORT4ME_EXCLUDE_UNSAFE_CHROME`:}{
#'   The set of ports that the Chrome web browser considers unsafe and
#'   therefore blocks.
#'   (Default: [ports blocked by Chrome](https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc))
#'  }
#'
#'  \item{`PORT4ME_EXCLUDE_UNSAFE_FIREFOX`:}{
#'   The set of ports that the Firefox web browser considers unsafe and
#'   therefore blocks.
#'   (Default: [ports blocked by Firefox](https://www-archive.mozilla.org/projects/netlib/portbanning#portlist))
#'  }
#' }
#'
#'
#' @section Settings for debugging:
#'
#' \describe{
#'  \item{`PORT4ME_DEBUG`:}{
#'   If `true`, extensive debug messages are generated.
#'   (Default: `false`)
#'  }
#' }
#'
#'
#' @examples
#' Sys.setenv(PORT4ME_EXCLUDE = "4444,5000-5999,8080")
#' port4me()
#' 
#'
#' @seealso
#' Environment variables can be configured for \R, by setting them in
#' your personal `~/.Renviron` file, e.g.
#'
#' ```
#' PORT4ME_EXCLUDE=4848,8080
#' ```
#'
#' For more information, see the \link[base]{Startup} help page.
#'
#' @aliases
#' PORT4ME_DEBUG
#' PORT4ME_TOOL
#' PORT4ME_USER
#' PORT4ME_SKIP
#' PORT4ME_PREPEND
#' PORT4ME_INCLUDE
#' PORT4ME_EXCLUDE
#' PORT4ME_PREPEND_SITE
#' PORT4ME_INCLUDE_SITE
#' PORT4ME_EXCLUDE_SITE
#' PORT4ME_EXCLUDE_UNSAFE
#' PORT4ME_EXCLUDE_UNSAFE
#' PORT4ME_EXCLUDE_UNSAFE_CHROME
#' PORT4ME_EXCLUDE_UNSAFE_FIREFOX
#'
#' @name port4me.settings
NULL
