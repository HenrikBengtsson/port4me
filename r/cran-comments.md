# CRAN submission port4me 0.5.0

## First submission

on 2022-10-25

This is a new package submission.

Thanks in advance


## Resubmission

on 2022-10-28

Updates per request from CRAN on this newbie submission:

1. Spell out initialism 'TCP' in the package description

2. Rephrase the starting sentence in the package description

3. Add URL reference for the "port4me" algorithm in the package description

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
── port4me 0.4.0-9010: OK

  Build ID:   port4me_0.4.0-9010.tar.gz-3cbf45da84f54115b6f120af75f06eb2
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  2h 24m 18.7s ago
  Build time: 1h 7m 39s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.4.0-9010: OK

  Build ID:   port4me_0.4.0-9010.tar.gz-9424edd3a695481caf160a104fba9fb4
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  2h 24m 18.7s ago
  Build time: 1h 3m 45.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.4.0-9010: OK

  Build ID:   port4me_0.4.0-9010.tar.gz-d5e86397996b4211a8fd3b885b4787c6
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  2h 24m 18.7s ago
  Build time: 43m 31.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.4.0-9010: OK

  Build ID:   port4me_0.4.0-9010.tar.gz-5c900f059701453eb82d0405b8022719
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  2h 24m 18.7s ago
  Build time: 3m 26.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── port4me 0.4.0-9010: OK

  Build ID:   port4me_0.4.0-9010.tar.gz-1d9e1c8651d549b9af3658add29aed25
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  2h 24m 18.7s ago
  Build time: 4m 49.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
