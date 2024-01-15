# Version (development version)

## Significant Changes

 * Remove arguments `min_port` and `max_port` from `port4me()`.

## Miscellaneous

 * Add unit test asserting that a bound port is detected as such.

## Bug Fixes

 * `port4me(test = port)` would throw an `OSError` exception instead
   of returning `False` if the port was busy.

 * `port4me(list = 0)` would behave like `list = 1`.  Now it gives an
   error.

 * `port4me(test = 0)` would ignore the `test` argument, effectively
   returning `port4me()`.  Now it gives a port-out-of-range error.


# Version 0.6.0 [2023-07-13]

## Significant Changes

 * Created Python package implementing the 'port4me' algorithm.  It
   provides both a Python API and a CLI API.  It is released on PyPI.
