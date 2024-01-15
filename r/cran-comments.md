# CRAN submission port4me 0.7.0

on 2024-01-15


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub | mac/win-builder |
| --------- | ------ | ----- | --------------- |
| 3.6.x     | L      |       |                 |
| 4.2.x     | L      |       |    W            |
| 4.3.x     | L M W  | L   W | M1 W            |
| devel     | L M W  | L     |    W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel", 
  "fedora-gcc-devel",
  "windows-x86_64-release",
  "linux-x86_64-rocker-gcc-san"
))
print(res)
```

gives

```
── port4me 0.7.0: OK

  Build ID:   port4me_0.7.0.tar.gz-9e8a1b7c077142119571224bc9050058
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  57m 42.4s ago
  Build time: 57m 36.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.7.0: OK

  Build ID:   port4me_0.7.0.tar.gz-a9e7bd8c61fe4511ba966c01ef367ad7
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  57m 42.4s ago
  Build time: 47m 0.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.7.0: OK

  Build ID:   port4me_0.7.0.tar.gz-215b69efec3449d69bc06029b0487f33
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  57m 42.4s ago
  Build time: 3m 37.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.7.0: OK

  Build ID:   port4me_0.7.0.tar.gz-98738a4c685747b5a773a8adb44406f3
  Platform:   Debian Linux, R-devel, GCC ASAN/UBSAN
  Submitted:  1h 41m 52.1s ago
  Build time: 1h 19m 56.4s
  
0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
