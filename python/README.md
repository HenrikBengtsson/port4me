# port4me: Get the Same, Personal, Free TCP Port over and over 

The **port4me** tool:

-   finds a free TCP port in \[1024,65535\] that the user can open

-   is designed to work in multi-user environments

-   gives different users, different ports

-   gives the user the same port over time with high probability

-   gives different ports for different software tools

-   requires no configuration

-   can be reproduced perfectly on all operating systems and in all
    common programming languages

## Introduction

There are many tools to identify a free TCP port, where most of them
return a random port. Although it works technically, it might add a fair
bit of friction if a new random port number has to be entered by the
user each time they need to use a specific tool.

In contrast, **port4me** attempts, with high probability, to provide the
user with the same port each time, even when used on different days. It
achieves this by scanning the same deterministic, pseudo-random sequence
of ports and return the first free port detected. Each user gets their
own random port sequence, lowering the risk for any two users to request
the same port. The randomness is initiated with a random seed that is a
function of the user’s name (`USER`), and, optionally, the name of the
software tool where we use the port.

The **port4me** algorithm can be implemented in most known programming
languages, producing perfectly reproducible sequencing regardless of
implementation language.

## A quick introduction

Assuming we’re logged in as user `alice`, calling `port4me.port4me()`
without arguments gives us a free port:

    >>> from getpass import getuser
    >>> getuser()
    "alice"
    >>> from port4me import port4me
    >>> port4me()
    30845

As we will see later, each user on the system is likely to get their own
unique port. Because of this, it can be used to specifying a port that
some tool should use, e.g.

    app.run(port=port4me())

As long as this port is available, `alice` will always get the same port
across Python sessions and over time. For example, if they return next week
and retry, it’s likely they still get:

    >>> port4me()
    30845

    >>> port4me()
    30845

However, if port 30845 is already occupied, the next port in the
pseudo-random sequence is considered, e.g.

    >>> port4me()
    19654

To see the first five ports scanned, run:

    >>> port4me(list=5)
    [30845, 19654, 32310, 63992, 15273]

## User-specific, deterministic, pseudo-random port sequence

This random sequence is initiated by a random seed that can be set via
the hashcode of a seed string. By default, it is based on the name of
the current user (e.g. environment variable `$USER`). For example, when
user `bob` uses the `port4me` tool, they see another set of ports being
scanned:

    >>> getuser()
    "bob"

    >>> port4me(list=5)
    [54242, 4930, 42139, 14723, 55707]


For testing and demonstration purposes, one can emulate another user by
specifying argument `user`, e.g.

    >>> getuser()
    "alice"
    >>> port4me()
    30845

    >>> port4me(user="bob")
    54242

    >>> port4me(user="carol")
    34307

## Different ports for different software tools

Sometimes a user would like to use two, or more, ports at the same time,
e.g. two ports for two different Shiny apps. In such case, they can
specify argument `tool`, which results in a port sequence that is unique
to both the user and the tool. For example,

    >>> port4me()
    30845

    >>> port4me("myapp")
    55578

    >>> port4me("demo")
    32273

This allows us to do:

    app.run(app_dir="myapp", port=port4me("myapp"))

and

    app.run(app_dir="demo", port=port4me("demo"))

## Avoid using ports commonly used elsewhere

Since there is a limited set of ports available (1024-65535), there is
always a risk that another process occupies any given port. The more
users there are on the same machine, the higher the risk is for this to
happen. If a user is unlucky, they might experience this frequently. For
example, `alice` might find that the first port (30845) works only one
out 10 times, the second port (19654) works 99 out 100 times, and the
third one (32310) works rarely. If so, they might choose to exclude the
ports that are most likely to be used by specifying them as a
comma-separated values via option `--exclude`, e.g.

    >>> port4me(exclude=[30845, 32310])
    19654

An alternative to specify them via a command-line option, is to specify
them via environment variable `PORT4ME_EXCLUDE`, e.g.

    {alice}$ PORT4ME_EXCLUDE=30845,32310
    ...
    >>> port4me()
    19654

To set this permanently, append:

    ## port4me customization
    ## https://github.com/HenrikBengtsson/port4me
    PORT4ME_EXCLUDE=30845,32310
    export PORT4ME_EXCLUDE

to the shell startup script, e.g. `~/.bashrc`.

This increases the chances for the user to end up with the same port
over time, which is convenient, because then they can reuse the same
call, which is available in the command-line history, each time without
having to change the port parameter.

The environment variable `PORT4ME_EXCLUDE` is intended to be used by the
individual user. To specify a set of ports to be excluded regardless of
user, set `PORT4ME_EXCLUDE_SITE`. For example, the systems
administrator, can choose to exclude an additional set of ports by
adding the following to file `/etc/profile.d/port4me.sh`:

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

In addition to ports excluded via above mechanisms, **port4me** excludes
ports that are considered unsafe by the Chrome and Firefox web browsers.
This behavior can be controlled by environment variable
`PORT4ME_EXCLUDE_UNSAFE`, which defaults to `{chrome},{firefox}`. Token
`{chrome}` expands to the value of `PORT4ME_EXCLUDE_UNSAFE_CHROME`,
which defaults to [the set of ports that Chrome
blocks](https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc)
and `{firefox}` expands to to the value of
`PORT4ME_EXCLUDE_UNSAFE_FIREFOX`, which defaults to [the set of ports
that Firefox
blocks](https://www-archive.mozilla.org/projects/netlib/portbanning#portlist).

Analogously to excluding a set of ports, one can limit the range of
ports to be scanned by specifying a list or str to the argument `include`, e.g.

    >>> port4me(include=[*range(2000, 2123+1), 4321, *range(10000, 10999+1)])
    10451

    >>> port4me(include="2000-2123,4321,10000-10999")
    10451

where the default corresponds to `include = 1024:65535`. Analogously to
`exclude`, `include` can be specified via environment variables
`PORT4ME_INCLUDE` and `PORT4ME_INCLUDE_SITE`.

## Scan a predefined set of ports before pseudo-random ones

In addition to scanning the user-specific, pseudo-random port sequence
for a free port, it is possible to also consider a predefined set of
ports prior to the random ones by specifying the argument
`prepend`, e.g.

    >>> port4me(prepend=[4321, 11001], list=5)
    [4321, 11001, 30845, 19654, 32310]

An alternative to specify them via a command-line option, is to specify
them via environment variable `PORT4ME_PREPEND`, e.g.

    {alice}$ PORT4ME_PREPEND=4321,11001
    ...
    >>> port4me(prepend=[4321, 11001], list=5)
    [4321, 11001, 30845, 19654, 32310]

The environment variable `PORT4ME_PREPEND` is intended to be used by the
individual user. To specify a set of ports to be prepended regardless of
user, set `PORT4ME_PREPEND_SITE`.

## Installation

To install the Python **port4me** package from [PyPI](https://pypi.org/project/port4me/), do:

    {alice}$ pip install port4me

To try it out, call:

    >>> from port4me import port4me
    >>> port4me("jupyter-notebook")
    29525

or

    {alice}$ python -m port4me --tool=jupyter-notebook
    29525
