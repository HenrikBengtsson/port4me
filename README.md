# [PROTOTYPE] port4me - Get the Same, Personal, Free TCP Port over and over

_WARNING: This is an experimental project under development. It is currently in a phase where features are explored and developed.  It is not ready for use. /Henrik 2022-07-15_


There exist many tools to identify a free TCP port, where most of them return a random port.  Although it works technically, it might add a fair bit of friction if a new random port number has to be entered by the user each time they need to use a specific tool.

To address this, **port4me** is language-agnostic algorithm that attempts, with high probability, to provide the user with the same port each time, even when used at different days.  It achieves this by scanning the same pseudo-random sequence of ports, where the random seed is a function of the user's name (`USER`) on the system, and, optionally, the name of the software where the port will be used.  The algorithm for generating the sequence of random ports can be perfectly reproduced in most known programming languages.  


## Example

From a Bash shell, running as user `alice`, we get:

```sh
{alice}$ port4me
53637
```

As long as this port is available, `alice` will always get the same port across shell sessions and over time.  For example, if they return week and retry, it's likely they still get:

```sh
{alice}$ port4me
53637
{alice}$ port4me
53637
```

However, if port 53637 is already occupied, the next port in the pseudo-random sequence is attempted, e.g.

```sh
{alice}$ port4me
14853
```

To see the first five ports scanned, run:

```sh
{alice}$ for skip in {0..4}; do PORT4ME_SKIP="$skip" port4me; done
53637
14853
55218
2354
35311
```

Since there is a limited set of ports available (1024-65535), there is always a risk that a port is occupied by another process.  The more users there are on the same machine, the higher the risk is for this to happen.  If a user is unlucky, they might experience this frequently.  For example, `alice` might find that the first port (53637) works only one out 10 times, whereas the the second port (14853) works 99 out 100 times.  If so, they might want to always skip the first port, and always start with the more "reliable" second port.  They can do this by setting environment variable `PORT4ME_SKIP`, e.g.

```sh
{alice}$ PORT4ME_SKIP=1 port4me
14853
```

To skip the first two ports, set `PORT4ME_SKIP=2`, and so on.  To set this permanently, append:

```sh
## port4me customization
## https://github.com/HenrikBengtsson/port4me
PORT4ME_SKIP=1
export PORT4ME_SKIP
```

to the shell startup script, e.g. `~/.bashrc`.

This increases the chances for the user to end up with the same port over time, which is convenient, because then they can reuse the exact same call, which is available in the command-line history, each time without having to modify the port parameter.


## User-specific, deterministic, pseudo-random port sequence

This random sequence is initiated by a random seed that can be set via the hashcode of a seed string.  By default, it is based on the name of the current user (e.g. environment variable `$USER`).  For example, when user `bob` uses the `port4me` tool, they see another set of ports being scanned:

```sh
{bob}$ for skip in {0..4}; do PORT4ME_SKIP="$skip" port4me; done
55266
5954
43163
15747
56731
```

For testing and demonstration purposes, one can emulate another user by specifying environment variable `PORT4ME_USER`, e.g.

```sh
{alice}$ port4me
53637
{alice}$ PORT4ME_USER=bob port4me
56731
{alice}$ PORT4ME_USER=carol port4me
35331
```

## Different ports for different software tools

Sometimes a user would like two use two, or more, ports at the same time, e.g. one port for RStudio Server and for Jupyter Hub.  In such case, they can set the optional `PORT4ME_TOOL` variable, which result in port sequence that is unique to both the user and the tool.  For example,

```sh
{alice}$ port4me
53637
{alice}$ PORT4ME_TOOL=rstudio port4me
39273
{alice}$ PORT4ME_TOOL=jupyter port4me
1147
```

This can be used to specify the port a specific software will use, e.g.

```sh
$jupyter notebook --port "$(PORT4ME_TOOL=jupyter port4me)"
```


## Roadmap 

* [x] Identify essential features
* [x] Prototype `port4me` command-line tool in Bash
* [x] Prototype `port4me` API and command-line tool in R
* [ ] Add support for `PORT4ME_EXCLUDE` and `PORT4ME_EXCLUDE_SITE`
* [ ] Standardize command-line interface between Bash and R implementations
* [ ] Prototype `port4me` API and command-line tool in Python


## The port4me Algorithm

### Requirements

* It should be possible to implement the algorithm using 32-bit _unsigned_ integer arithmetic.  One must not assume that the largest represented integer can exceed 2^32.

* At a minimum, it should be possible to implement the algorithm in vanilla Sh\*, Csh, Bash, C, C++, Fortran, Lua, Python, R, and Ruby, _without_ the need for add-on packages beyond what is available from their core distribution. (*) Shells that do not support integer arithmetic, may use tools such as `expr`, `dc`, `bc`, and `awk` for these calculations.

* All programming languages should produce the exact same pseudo-random port sequences given the same random seed.

* The implementations should be written such that they work also when sourced, or copy'and'pasted into source code elsewhere, e.g. in R and Python scripts.

* The user should be able to skip a certain number of random ports at their will by specifying environment variable `PORT4ME_SKIP`, e.g. `PORT4ME_SKIP=5`.  The default is to not skip, which corresponds to `PORT4ME_SKIP=0`.

* The user should be able to skip a predefined set of ports by specifying environment variable `PORT4ME_EXCLUDE`, e.g. `PORT4ME_EXCLUDE=8080,4321`.

* The system administrator should be able to specify a predefined set of ports to be excluded by specifying environment variable `PORT4ME_EXCLUDE_SITE`, e.g. `PORT4ME_EXCLUDE_SITE=8080,4321`.  This works complementary to `PORT4ME_EXCLUDE`.

* New implementations should perfectly reproduce the port sequences produced by already existing implementations.


### Design

* A _[Linear congruential generator (LCG)](https://en.wikipedia.org/wiki/Linear_congruential_generator)_ will be used to generate the pseudo-random port sequence

* A _32-bit integer string hashcode_ will be used to generate a valid random seed from an ASCII character string of any length. The hashcode algorithm is based on the Java hashcode algorithm, but uses unsigned 32-bit integers instead of signed ones
