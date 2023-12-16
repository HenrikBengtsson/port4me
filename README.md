[![Bash checks](https://github.com/HenrikBengtsson/port4me/actions/workflows/check-bash.yml/badge.svg)](https://github.com/HenrikBengtsson/port4me/actions/workflows/check-bash.yml)

[![PyPI version](https://img.shields.io/pypi/v/port4me)](https://pypi.org/project/port4me/)
[![Python checks](https://github.com/HenrikBengtsson/port4me/actions/workflows/check-python.yml/badge.svg)](https://github.com/HenrikBengtsson/port4me/actions/workflows/check-python.yml)
[![Python Code Coverage](https://codecov.io/gh/HenrikBengtsson/port4me/graph/badge.svg)](https://codecov.io/gh/HenrikBengtsson/port4me)

[![R-CRAN check status](https://www.r-pkg.org/badges/version/port4me)](https://CRAN.R-project.org/web/checks/check_results_port4me.html)
[![R checks](https://github.com/HenrikBengtsson/port4me/actions/workflows/check-r.yml/badge.svg)](https://github.com/HenrikBengtsson/port4me/actions/workflows/check-r.yml)
[![R Code Coverage](https://codecov.io/gh/HenrikBengtsson/port4me/graph/badge.svg)](https://codecov.io/gh/HenrikBengtsson/port4me)


# port4me - Get the Same, Personal, Free TCP Port over and over

The **[port4me]** tool:

* finds a free TCP port in [1024,65535] that the user can open

* is designed to work in multi-user environments

* gives different users, different ports

* gives the user the same port over time with high probability

* gives different ports for different software tools

* requires no configuration

* is implemented in Bash, Python, and R

* can be reproduced perfectly on all operating systems and in all
  common programming languages


## Introduction

There are many tools to identify a free TCP port, where most of them
return a random port.  Although it works technically, it might add a
fair bit of friction if a new random port number has to be entered by
the user each time they need to use a specific tool.

In contrast, **port4me** attempts, with high probability, to provide
the user with the same port each time, even when used on different
days.  It achieves this by scanning the same deterministic,
pseudo-random sequence of ports and return the first free port
detected.  Each user gets their own random port sequence, lowering the
risk for any two users to request the same port.  The randomness is
initiated with a random seed that is a function of the user's name
(`USER`), and, optionally, the name of the software where we use the
port.

The **port4me** algorithm can be implemented in most known programming
languages, producing perfectly reproducable sequencing regardless of
implementation language.


## A quick introduction

Assuming we're logged in as user `alice` in a Bash shell, calling
`port4me` without arguments gives us a free port:

```sh
{alice}$ port4me
30845
```

As we will see later, each user on the system is likely to get their
own unique port.  Because of this, it can be used to specifying a port
that some software tool should use, e.g.

```sh
{alice}$ jupyter notebook --port "$(port4me)"
```

As long as this port is available, `alice` will always get the same
port across shell sessions and over time.  For example, if they return
next week and retry, it's likely they still get:

```sh
{alice}$ port4me
30845
{alice}$ port4me
30845
```

However, if port 30845 is already occupied, the next port in the
pseudo-random sequence is considered, e.g.

```sh
{alice}$ port4me
19654
```

To see the first five ports scanned, run:

```sh
{alice}$ port4me --list=5
30845
19654
32310
63992
15273
```


## User-specific, deterministic, pseudo-random port sequence

This random sequence is initiated by a random seed that can be set via
the hashcode of a seed string.  By default, it is based on the name of
the current user (e.g. environment variable `$USER`).  For example,
when user `bob` uses the `port4me` tool, they see another set of ports
being scanned:

```sh
{bob}$ port4me --list=5
54242
4930
42139
14723
55707
```

For testing and demonstration purposes, one can emulate another user
by specifying option `--user`, e.g.

```sh
{alice}$ port4me
30845
{alice}$ port4me --user=bob
54242
{alice}$ port4me --user=carol
34307
```

## Different ports for different software tools

Sometimes a user would like to use two, or more, ports at the same
time, e.g. one port for RStudio Server and another for Jupyter
Notebook.  In such case, they can specify option `--tool`, which
results in a port sequence that is unique to both the user and the
tool.  For example,

```sh
{alice}$ port4me
30845
{alice}$ port4me --tool=rstudio
22486
{alice}$ port4me --tool=jupyter-notebook
29525
```

For conveniency, if the first option is unnamed, then it is assumed it
specifies the `--tool` option.  This means we can use the following
sort form as well:

```sh
{alice}$ port4me jupyter-notebook
47467
```

This allows us to get different ports for different software tools, e.g.

```sh
{alice}$ rserver --www-port "$(port4me rstudio)"
```

and

```sh
{alice}$ jupyter notebook --port "$(port4me jupyter-notebook)"
```


## Avoid using ports commonly used elsewhere

Since there is a limited set of ports available (1024-65535), there is
always a risk that another process occupies any given port.  The more
users there are on the same machine, the higher the risk is for this
to happen.  If a user is unlucky, they might experience this
frequently.  For example, `alice` might find that the first port
(30845) works only one out 10 times, the second port (19654) works 99
out 100 times, and the third one (32310) works rarely.  If so, they
might choose to exclude the ports that are most likely to be occupied
by specifying them as a comma-separated values via option `--exclude`,
e.g.

```sh
{alice}$ port4me --exclude=30845,32310
19654
```

An alternative to specify them via a command-line option, is to
specify them via environment variable `PORT4ME_EXCLUDE`, e.g.

```sh
{alice}$ PORT4ME_EXCLUDE=30845,32310 port4me
19654
```

To set this permanently, append:

```sh
## port4me customization
## https://github.com/HenrikBengtsson/port4me
PORT4ME_EXCLUDE=30845,32310
export PORT4ME_EXCLUDE
```

to the shell startup script, e.g. `~/.bashrc`.

This increases the chances for the user to end up with the same port
over time, which is convenient, because then they can reuse the same
call, which is available in the command-line history, each time
without having to change the port parameter.


The environment variable `PORT4ME_EXCLUDE` is intended to be used by
the individual user.  To specify a set of ports to be excluded
regardless of user, set `PORT4ME_EXCLUDE_SITE`.  For example, the
systems administrator, can choose to exclude an additional set of
ports by adding the following to file `/etc/profile.d/port4me.sh`:

```sh
## port4me: always exclude commonly used ports
## https://github.com/HenrikBengtsson/port4me

PORT4ME_EXCLUDE_SITE=

## MySQL
PORT4ME_EXCLUDE_SITE=$PORT4ME_EXCLUDE_SITE,3306

## ZeroMQ
PORT4ME_EXCLUDE_SITE=$PORT4ME_EXCLUDE_SITE,5670

## Redis
PORT4ME_EXCLUDE_SITE=$PORT4ME_EXCLUDE_SITE,6379

## Jupyter
PORT4ME_EXCLUDE_SITE=$PORT4ME_EXCLUDE_SITE,8888

export PORT4ME_EXCLUDE_SITE
```

In addition to ports excluded via above mechanisms, **port4me**
excludes ports that are considered unsafe by the Chrome and Firefox
web browsers.  This behavior can be controlled by environment variable
`PORT4ME_EXCLUDE_UNSAFE`, which defaults to `{chrome},{firefox}`.
Token `{chrome}` expands to the value of
`PORT4ME_EXCLUDE_UNSAFE_CHROME`, which defaults to [the set of ports
that Chrome blocks], and `{firefox}` expands to to the value of
`PORT4ME_EXCLUDE_UNSAFE_FIREFOX`, which defaults to [the set of ports
that Firefox blocks].


Analogously to excluding a set of ports, one can limit the range of
ports to be scanned by specifying command-line option `--include`,
e.g.

```sh
{alice}$ port4me --include=2000-2123,4321,10000-10999
10451
```

where the default corresponds to `--include=1024-65535`.  Analogously
to `--exclude`, `--include` can be specified via environment variables
`PORT4ME_INCLUDE` and `PORT4ME_INCLUDE_SITE`.



## Scan a predefined set of ports before pseudo-random ones

In addition to scanning the user-specific, pseudo-random port sequence
for a free port, it is possible to also consider a predefined set of
ports prior to the random ones by specifying command-line option
`--prepend`, e.g.

```sh
{alice}$ port4me --prepend=4321,11001 --list=5
4321
11001
30845
19654
32310
```

An alternative to specify them via a command-line option, is to
specify them via environment variable `PORT4ME_PREPEND`, e.g.

```sh
{alice}$ PORT4ME_PREPEND=4321,11001 port4me --list=5
4321
11001
30845
19654
32310
```

The environment variable `PORT4ME_PREPEND` is intended to be used by
the individual user.  To specify a set of ports to be prepended
regardless of user, set `PORT4ME_PREPEND_SITE`.



## Tips and Tricks

All **port4me** implementations output the identified port to standard
output (stdout). This makes it easy to capture by standard shell
methods, e.g. `port="$(port4me)"`.  If you'd like to see which port
number was generated, use `tee` to send the port also to the standard
error (stderr), which can be seen in the terminal. For example,

```sh
{alice}$ jupyter notebook --port "$(port4me --tool=jupyter-notebook | tee /dev/stderr)"
29525
```


## Installation

### Bash, command-line tool

To install the Bash version of **portme**, do:

```sh
VERSION=0.6.0
curl -L -O https://github.com/HenrikBengtsson/port4me/archive/refs/tags/"${VERSION}.tar.gz"
tar -x -f "${VERSION}.tar.gz"
export PREFIX=/path/to/port4me/   ## must be an absolute path to a folder
(cd "port4me-${VERSION}/bash"; make install)
```

Then run it as:

```sh
$ export PATH=/path/to/port4me/bin:$PATH
$ port4me --version
0.6.0
```

### R package

To install the R **portme** package, which is available on
[CRAN](https://cran.r-project.org/package=port4me), call the following
from within R:

```r
install.packages("port4me")
```

To install the development version, do:

```r
remotes::install_github("HenrikBengtsson/port4me", subdir = "r")
```

To try it out, call:

```r
> port4me::port4me("jupyter-notebook")
[1] 47467
```

or

```sh
$ Rscript -e port4me::port4me jupyter-notebook
29525
```


### Python package

The Python package **port4me** is available
[PyPI](https://pypi.org/project/port4me/). To install the Python
**portme** package to your personal Python package library, call the
following from the command line:

```sh
$ pip install --user port4me
```

To install it to a Python virtual environment, drop option `--user`.

To try it out, call:

```r
>>> from port4me import port4me
>>> port4me("jupyter-notebook")
29525
```

or

```sh
$ python -m port4me --tool=jupyter-notebook
29525
```


## The port4me Algorithm

### Requirements

* It should be possible to implement the algorithm using 32-bit
  _unsigned_ integer arithmetic.  One must not assume that the largest
  represented integer can exceed $2^{32} - 1$.

* The pseudo-randomized port sequence should sample ports uniformly
  over $[1024, 65535]$.

* At a minimum, it should be possible to implement the algorithm in
  vanilla Sh\*, Csh, Bash, C, C++, Fortran, Lua, Python, R, and Ruby,
  with _no_ need for add-on packages beyond what is available from
  their core distribution. (*) Shells that do not support integer
  arithmetic may use tools such as `expr`, `dc`, `bc`, and `awk` for
  these calculations.

* All programming languages should produce the exact same
  pseudo-random port sequences given the same random seed.

* The implementations should be written such that they work also when
  sourced, or copy'and'pasted into source code elsewhere, e.g. in R
  and Python scripts.

* The identified, free port should be outputted to the standard output
  (stdout) as digits only, without any prefix or suffix symbols.

* The user should be able to exclude a pre-defined set of ports by
  specifying environment variable `PORT4ME_EXCLUDE`,
  e.g. `PORT4ME_EXCLUDE=8080,4321`.

* The system administrator should be able to specify a pre-defined set
  of ports to be excluded by specifying environment variable
  `PORT4ME_EXCLUDE_SITE`, e.g. `PORT4ME_EXCLUDE_SITE=8080,4321`.  This
  works complementary to `PORT4ME_EXCLUDE`.

* The user should be able to skip a certain number of random ports at
  their will by specifying environment variable `PORT4ME_SKIP`,
  e.g. `PORT4ME_SKIP=5`.  The default is to not skip, which
  corresponds to `PORT4ME_SKIP=0`. Skipping should apply _after_ ports
  are excluding by `PORT4ME_EXCLUDE` and `PORT4ME_EXCLUDE_SITE`.

* New implementations should perfectly reproduce the port sequences
  produced by already existing implementations.


### Design

* A _[Linear congruential generator (LCG)]_ will be used to generate
  the pseudo-random port sequence

  - the next seed, $s_{n+1}$ is calculated based on the current seed
    $s_n$ and parameters $a, c, m > 1$ as
    $s_{n+1} = (a * s_{n} + c) \% m$

  - the LCG algorithm must not assume that the current LCG seed is
    within $[0,m-1]$, i.e. it should apply modulo $m$ on the seed
    first to avoid integer overflow

  - the LCG algorithm may produce the same output seed as input seed,
    which may happen when the seed is $s_n = m - (a - c)$.  To avoid
    this resulting in a constant LCG stream, increment the seed by one
    and recalculate whenever this happens

  - LCG parameters should be $m = 2^{16} + 1$, $a = 75$, and $c = 74$
    ("ZX81")
  
     - this requires only 32-bit integer arithmetic, because
       $m < 2^{32}$
     
     - if the initial seed is $s_0 = m - (a - c)$, which here is
       $m - 1 = 2^{16}$, then the next LCG seed will be the same, 
       which is then handled by the above increment-by-one workaround
  
* A _32-bit integer string hashcode_ will be used to generate an
  integer in $[0,2^{32}-1]$ from an ASCII string with any number of
  characters. The hashcode algorithm is based on the Java hashcode
  algorithm, but uses unsigned 32-bit integers in $[0,2^{32}-1]$,
  instead of signed ones in $[-2^{31},2^{31}-1]$

* The string hashcode is used as the initial LCG seed:

  - the LCG seed should be in $[0,m-1]$
  
  - given hashcode $h$, we can generate the initial LCG seed as $h$
    modulo $m$


[port4me]: https://github.com/HenrikBengtsson/port4me
[the set of ports that Chrome blocks]: https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc
[the set of ports that Firefox blocks]: https://www-archive.mozilla.org/projects/netlib/portbanning#portlist
[Linear congruential generator (LCG)]: https://en.wikipedia.org/wiki/Linear_congruential_generator
