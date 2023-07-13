# CRAN submission port4me 0.6.0

on 2023-07-13


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub  | mac/win-builder |
| --------- | ------ | ------ | --------------- |
| 4.0.x     | L      |        |                 |
| 4.2.x     | L      |        |                 |
| 4.3.x     | L M W  | L M    | M1 W            |
| devel     | L M W  | L      |    W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel", 
  "debian-gcc-patched", 
  "fedora-gcc-devel"
##  "windows-x86_64-release"  ## currently unavailable
))
print(res)
```

gives

```
── port4me 0.6.0: OK

  Build ID:   port4me_0.6.0.tar.gz-9a411af7294b406db1e1653fe65c69b3
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  28m 9.7s ago
  Build time: 20m 51.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.6.0: OK

  Build ID:   port4me_0.6.0.tar.gz-beb11d9627d342e3b32da7d180b5b758
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  28m 9.7s ago
  Build time: 18m 52.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.6.0: OK

  Build ID:   port4me_0.6.0.tar.gz-aac990e589ac4769b5cd7ad774c32101
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  28m 9.8s ago
  Build time: 14m 23.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
