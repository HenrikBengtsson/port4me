# Version (development version)

## New Features

* Add `port4me --include=<ports>`.


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
