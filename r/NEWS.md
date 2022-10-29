# Version 0.5.0 [2022-10-25]

## New Features

 * Added environment variable `PORT4ME_EXCLUDE_UNSAFE`, which defaults
   to `{chrome},{firefox}`.  The token `{chrome}` expands to the value
   of `PORT4ME_EXCLUDE_UNSAFE_CHROME`, which defaults to the set of
   ports that are considered unsafe by the Chrome web browser and
   therefore also blocked by it.  Similarly, `{firefox}` expands to
   the value of `PORT4ME_EXCLUDE_UNSAFE_FIXEFOX`, which defaults to
   the set of ports that are blocked by Mozilla Firefox web browser.
 

# Version 0.4.0 [2022-08-25]

## Significant Changes

 * Created R package based on a set of prototypical R scripts.

