![lifecycle: experimental](images/lifecycle-experimental-orange.svg)

# port4me - Get the Same, Personal, Free TCP Port over and over

_WARNING: This is an experimental project under development. It is currently in a phase where features are explored and developed. Feel free to give it a spin and give feedback. /Henrik 2022-07-16_


There are many tools to identify a free TCP port, where most of them return a random port.  Although it works technically, it might add a fair bit of friction if a new random port number has to be entered by the user each time they need to use a specific tool.

To address this, **port4me** is a language-agnostic algorithm that attempts, with high probability, to provide the user with the same port each time, even when used on different days.  It achieves this by scanning the same sequence of ports, where the random seed is a function of the user's name (`USER`) on the system, and, optionally, the name of the software where we use the port.  The algorithm that **port4me** use for generating the determisitic, pseudo-random port sequence is designed such that it can be reproduced perfectly in most known programming languages.


## Example

From a Bash shell, running as user `alice`, we get:

```sh
{alice}$ port4me
31869
```

As we will see later, each user on the system is likely to get their own unique port.  Because of this, it can be used to specifying a port that some software tool should use, e.g.

```sh
{alice}$ jupyter notebook --port "$(port4me)"
```

As long as this port is available, `alice` will always get the same port across shell sessions and over time.  For example, if they return week and retry, it's likely they still get:

```sh
{alice}$ port4me
31869
{alice}$ port4me
31869
```

However, if port 53637 is already occupied, the next port in the pseudo-random sequence is considered, e.g.

```sh
{alice}$ port4me
20678
```

To see the first five ports scanned, run:

```sh
{alice}$ port4me --list=5
31869
20678
33334
65016
16297
```

Since there is a limited set of ports available (1024-65535), there is always a risk that another process occupies any given port.  The more users there are on the same machine, the higher the risk is for this to happen.  If a user is unlucky, they might experience this frequently.  For example, `alice` might find that the first port (31869) works only one out 10 times, whereas the second port (20678) works 99 out 100 times, and the third one (33334) works so and so.  If so, they might choose to exclude the "flaky" ports by specifying them as a comma-separated values via option `--exclude`, e.g.

```sh
{alice}$ port4me --exclude=31869,33334
20678
```

An alternative to specify them via a command-line option, is to specify them via environment variable `PORT4ME_EXCLUDE`, e.g.

```sh
{alice}$ PORT4ME_EXCLUDE=31869,33334 port4me
20678
```

To set this permanently, append:

```sh
## port4me customization
## https://github.com/HenrikBengtsson/port4me
PORT4ME_EXCLUDE=31869,33334
export PORT4ME_EXCLUDE
```

to the shell startup script, e.g. `~/.bashrc`.

This increases the chances for the user to end up with the same port over time, which is convenient, because then they can reuse the same call, which is available in the command-line history, each time without having to change the port parameter.


## User-specific, deterministic, pseudo-random port sequence

This random sequence is initiated by a random seed that can be set via the hashcode of a seed string.  By default, it is based on the name of the current user (e.g. environment variable `$USER`).  For example, when user `bob` uses the `port4me` tool, they see another set of ports being scanned:

```sh
{bob}$ port4me --list=5
55266
5954
43163
15747
56731
```

For testing and demonstration purposes, one can emulate another user by specifying option `--user`, e.g.

```sh
{alice}$ port4me
53637
{alice}$ port4me --user=bob
56731
{alice}$ port4me --user=carol
35331
```

## Different ports for different software tools

Sometimes a user would like to use two, or more, ports at the same time, e.g. one port for RStudio Server and another for Jupyter Hub.  In such case, they can specify option `--tool`, which results in a port sequence that is unique to both the user and the tool.  For example,

```sh
{alice}$ port4me
31869
{alice}$ port4me --tool=rstudio
39273
{alice}$ port4me --tool=jupyter
1147
```

This allows us to do:

```sh
{alice}$ rserver --www-port "$(port4me --tool=rstudio)"
```

and

```sh
{alice}$ jupyter notebook --port "$(port4me --tool=jupyter)"
```



## Roadmap 

* [x] Identify essential features
* [x] Prototype `port4me` command-line tool in Bash, e.g. `port4me --list=5`
* [x] Prototype `port4me` API and command-line tool in R, e.g. `Rscript port4me.R --list=5`
* [x] Add support for `PORT4ME_EXCLUDE`
* [x] Add support for `PORT4ME_EXCLUDE_SITE`
* [x] Standardize command-line interface between Bash and R implementations
* [ ] The string-to-seed algorithm rely on [0,2^32-1] integer arithmetic; can this be lowered to [0,2^16-1] = [0,65535] given we're dealing with TCP ports, which has the latter range?
* [ ] Prototype `port4me` API and command-line tool in Python


## The port4me Algorithm

### Requirements

* It should be possible to implement the algorithm using 32-bit _unsigned_ integer arithmetic.  One must not assume that the largest represented integer can exceed 2^32.

* At a minimum, it should be possible to implement the algorithm in vanilla Sh\*, Csh, Bash, C, C++, Fortran, Lua, Python, R, and Ruby, with _no_ need for add-on packages beyond what is available from their core distribution. (*) Shells that do not support integer arithmetic may use tools such as `expr`, `dc`, `bc`, and `awk` for these calculations.

* All programming languages should produce the exact same pseudo-random port sequences given the same random seed.

* The implementations should be written such that they work also when sourced, or copy'and'pasted into source code elsewhere, e.g. in R and Python scripts.

* The user should be able to skip a pre-defined set of ports by specifying environment variable `PORT4ME_EXCLUDE`, e.g. `PORT4ME_EXCLUDE=8080,4321`.

* The system administrator should be able to specify a pre-defined set of ports to be excluded by specifying environment variable `PORT4ME_EXCLUDE_SITE`, e.g. `PORT4ME_EXCLUDE_SITE=8080,4321`.  This works complementary to `PORT4ME_EXCLUDE`.

* The user should be able to skip a certain number of random ports at their will by specifying environment variable `PORT4ME_SKIP`, e.g. `PORT4ME_SKIP=5`.  The default is to not skip, which corresponds to `PORT4ME_SKIP=0`.

* New implementations should perfectly reproduce the port sequences produced by already existing implementations.


### Design

* A _[Linear congruential generator (LCG)](https://en.wikipedia.org/wiki/Linear_congruential_generator)_ will be used to generate the pseudo-random port sequence
  - the current implementation use the "ZX81" LCG with parameters $m=2^16 + 1$, $a=75$, and $c=74$.

* A _32-bit integer string hashcode_ will be used to generate a valid random seed from an ASCII character string of any length. The hashcode algorithm is based on the Java hashcode algorithm, but uses unsigned 32-bit integers in $[0,2^32-1]$, instead of signed ones in $[-2^31,2^31-1]$
