# Version (development version)

## Significant Changes

 * Now package works also on R (< 4.0.0).

## Miscellaneous

 * Add unit test asserting that a bound port is detected as such.
 
 * Remove unnecessary whitespace prefix from the CLI help output.

## Bug Fixes

 * `port4me()` would only verify that it was possible to listen to 
   port. Now it also verifies that the port can be bound.
 
 * The command-line interface gave an error if special R option
   `--args` was used as in `Rscript -e port4me::port4me --args
   --list=5`.


# Version 0.6.0 [2023-07-13]

## New Features

 * Add command-line interface for R, e.g. `Rscript -e
   port4me::port4me`, `Rscript -e port4me::port4me --list=5`,
   `Rscript -e port4me::port4me --test=8087`.

## Miscellaneous

 * Two of the examples for excluding ports had the wrong output.

## Bug Fixes

 * If argument `prepend` was a numeric, but not an integer, then the
   return port, or ports, would also be numeric. Now `port4me()`
   returns integer ports also when `prepend` is numeric.

 * The R `port4me::port4me()` function did not default to environment
   variable `PORT4ME_LIST`, if argument `list` was not specified.

 * The R `port4me::port4me()` function did not default to environment
   variable `PORT4ME_TEST`, if argument `test` was not specified.


# Version 0.5.1 [2023-03-23]

## Miscellaneous

 * Fix incorrect static output in vignette by generating it
   dynamically, e.g. some ports listed are not the ones expected.
 

# Version 0.5.0 [2022-10-25]

## New Features

 * Added environment variable `PORT4ME_EXCLUDE_UNSAFE`, which defaults
   to `{chrome},{firefox}`.  The token `{chrome}` expands to the value
   of `PORT4ME_EXCLUDE_UNSAFE_CHROME`, which defaults to the set of
   ports that are considered unsafe by the Chrome web browser and
   therefore also blocked by it.  Similarly, `{firefox}` expands to
   the value of `PORT4ME_EXCLUDE_UNSAFE_FIXEFOX`, which defaults to
   the set of ports that are blocked by the Mozilla Firefox web browser.
 

# Version 0.4.0 [2022-08-25]

## Significant Changes

 * Created R package based on a set of prototypical R scripts.

