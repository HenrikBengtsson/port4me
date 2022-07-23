# Version (development version)

* ...


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
