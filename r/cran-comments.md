# CRAN submission port4me 0.5.0

on 2022-10-25

This is a new package submission.

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub  | mac/win-builder |
| --------- | ------ | ------ | --------------- |
| 4.0.x     | L      |        |                 |
| 4.1.x     | L      |        |                 |
| 4.2.x     | L M W  | L M W  | M1 W            |
| devel     | L M W  | L      |    W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel", 
  "debian-gcc-patched", 
  "fedora-gcc-devel",
  "macos-highsierra-release-cran",
  "windows-x86_64-release"
))
print(res)
```

gives

```
── port4me 0.5.0: OK

  Build ID:   port4me_0.5.0.tar.gz-ccf4911fb4d9488881adf398956a7682
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  37m 13.1s ago
  Build time: 37m 6.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.5.0: OK

  Build ID:   port4me_0.5.0.tar.gz-52444aef82ba46af95924d292228e6db
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  37m 13.2s ago
  Build time: 32m 28.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.5.0: OK

  Build ID:   port4me_0.5.0.tar.gz-8d8f4882b9f84af781184cbd2d53c9cd
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  37m 13.2s ago
  Build time: 22m 59.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.5.0: OK

  Build ID:   port4me_0.5.0.tar.gz-aebc89c6aca046afa7bc548e3bf889fc
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  37m 13.2s ago
  Build time: 3m 15.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.5.0: OK

  Build ID:   port4me_0.5.0.tar.gz-f44b9a34e5db498491b098f080045a05
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  37m 13.2s ago
  Build time: 4m 35s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
