# CRAN submission port4me 0.5.1

on 2023-03-23


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub  | mac/win-builder |
| --------- | ------ | ------ | --------------- |
| 4.0.x     | L      |        |                 |
| 4.1.x     | L      |        |                 |
| 4.2.x     | L M W  | L M W  | M1 W            |
| devel     | L M W  | L      | M1 W            |

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
── port4me 0.5.1: OK

  Build ID:   port4me_0.5.1.tar.gz-1060bf522b8a4eab81f2ec4686f95e1a
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  1h 20m 24.1s ago
  Build time: 1h 8m 10.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.5.1: OK

  Build ID:   port4me_0.5.1.tar.gz-d633fdec9ce94b3baa1234d48f467629
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  1h 20m 24.1s ago
  Build time: 1h 7m 15.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.5.1: OK

  Build ID:   port4me_0.5.1.tar.gz-9cbefe157f4b466f9a6a3196a6db9823
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  1h 20m 24.1s ago
  Build time: 47m 39.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.5.1: OK

  Build ID:   port4me_0.5.1.tar.gz-990dd53490eb4bbaa82221365de872ca
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  1h 20m 24.1s ago
  Build time: 5m 9.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.5.1: OK

  Build ID:   port4me_0.5.1.tar.gz-53d277c9b3974db29777f2fa4600ba6b
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  1h 20m 24.1s ago
  Build time: 3m 34.7s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
