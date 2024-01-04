# Version (development version)

## Miscellaneous

* Add unit test asserting that a bound port is detected as such.

## Bug Fixes

* `port4me(test = port)` would throw an `OSError` exception instead of
  returning `False` if the port was busy.


# Version 0.6.0 [2023-07-13]

## Significant Changes

 * Created Python package implementing the 'port4me' algorithm.  It
   provides both a Python API and a CLI API.  It is released on PyPI.
