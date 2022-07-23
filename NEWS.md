# Version (development version)

## Bug Fixes

* The LCG algorithm can get stuck and produce an constant stream for
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
