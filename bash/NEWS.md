# Version (development version)

## Miscellaneous

 * Remove unnessary whitespace prefix from the CLI help output.


# Version 0.6.0 [2023-07-13]

## Significant Changes

 * Changed the license from ISC to MIT in order to harmonize it with
   the Python and R implementations.
 
## Bug Fixes
 
 * Prepending ports, e.g. `port4me --prepend=<ports>`, did not
   work since version 0.4.0. Any ports specified where ignored.
 
 
# Version 0.5.1 [2023-03-23]
 
## Significant Changes
 
 * `port4me <tool>` is now short for `port4me --tool=<tool>`.  Such an
   "unnamed" `--tool` option is only allowed if specified in the first
   location, otherwise it is considered an error.  This is analogue to
   not naming the `tool` argument in R, which is the first argument,
   e.g. `port4me::port4me(<tool>)`.
 
## New Features
 
 * Now `port4me` can also use `netstat` to test whether a port is
   available or not.
 
## Bug Fixes
 
 * `port4me` failed to produce the intended error message in some
   cases, e.g.  `port4me --user=""` gave `error: command not found`
   instead of `ERROR: Option '--user' must not be empty`.
 
 
# Version 0.5.0 [2022-10-29]
 
## New Features
 
 * Added environment variable `PORT4ME_EXCLUDE_UNSAFE`, which defaults
   to `{chrome},{firefox}`.  The token `{chrome}` expands to the value
   of `PORT4ME_EXCLUDE_UNSAFE_CHROME`, which defaults to the set of
   ports that are considered unsafe by the Chrome web browser and
   therefore also blocked by it.  Similarly, `{firefox}` expands to the
   value of `PORT4ME_EXCLUDE_UNSAFE_FIXEFOX`, which defaults to the set
   of ports that are blocked by Mozilla Firefox web browser.
 
 
# Version 0.4.0 [2022-08-25]
 
## New Features
 
 * Now `port4me` memoized which system command (`nc` or `ss`) to use to
   test whether a port is available or not.
 
## Design
 
 * The LCG parameters are now frozen to `modulus = 2^16+1`, `a = 75`,
   and `c = 74`.
 
## Bug Fixes
 
 * `port4me` stuck indefinitely if none of the ports scanned could be
   opened.
 
 * `port4me --list=n --exclude=<ports>` would return fewer than `n`
   ports if some of the `n` ports were excluded.
 
 
# Version 0.3.0 [2022-07-25]
 
## Significant Changes
 
 * Renamed former `--include=<ports>` to `--prepend=<ports>`.
 
## New Features
 
 * Add `--include=<ports>` for specifying ports to be considered.
   The default is 1024-65535.
 
 * Now `--exclude` and `--prepend` supports port ranges to, e.g.
   `--exclude=1024-2048,4019`.
 
 
# Version 0.2.1 [2022-07-25]
 
## New Features
 
 * Now `port4me` falls back to the `ss` command, if the `nc` command is
   not available.  If neither are available, and informative error
   message is produced.
   
## Bug Fixes
 
 * `port4me` would give an error message if command `nc` is not
   available, but still output a port number without validating it is
   available.  Now it gives an informative error and terminates.
   
 
# Version 0.2.0 [2022-07-25]
 
## New Features
 
 * Add `port4me --include=<ports>` to consider a given set of ports
   _before_ considering the pseudo-random port sequence.
 
## Bug Fixes
 
 * Bash implementation would consider a free port in 1-1023 as
   openable, even if the user has no right to open it.
 
 
# Version 0.1.0 [2022-07-24]
 
## Significant Changes
 
 * The new accept-reject sampling technique (see below bug fix) results
   in different port sequences than before.
 
## Bug Fixes
 
 * The **port4me** algorithm did not sample uniformly from
   [1024,65535].  The was fixed by replacing the remapping from LCG
   samples in [0, 65535] to [1024,65535] from a modulus method to using
   an accept-reject sampling technique.
   
 
# Version 0.0.4 [2022-07-24]
 
## New Features
 
 * Add `port4me --test=<port>` to check if a port is free or not.
 
 
# Version 0.0.3 [2022-07-23]
 
## Bug Fixes
 
 * The LCG algorithm can get stuck and produce a constant stream for
   certain values of LCG seed and LCG parameters.  To avoid this, we
   detect when it happens, and increment the LCG seed by one, and
   generate the next LCG seed.
 
 * The Bash implementation produced an error if the LCG seed was 0.
 
 
# Version 0.0.2 [2022-07-23]
 
## Significant Changes
 
 * LCG seed is forced into the LCG limits before being used by applying
   the LCG modulo.  This helps avoid integer overflow in some
   implementations.
 
## Miscellaneous
 
 * Added `make install` to help install the Bash implementation.
 
 * Run all tests via GitHub Actions.
 
 
# Version 0.0.1 [2022-07-22]
 
 * Created. Under development.
