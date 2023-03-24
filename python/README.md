# port4me - Get the Same, Personal, Free TCP Port over and over

_WARNING_: This Python package is under development and incomplete. It will eventually implement the **[port4me]** algorithm, which is currently implemented in Bash and R. /2023-03-23


## Examples of what currently works

```sh
{alice}$ python -m port4me
30845
{alice}$ python -m port4me
30845
```

```sh
{alice}$ python -c 'from port4me import port4me; print(port4me())'
30845
```

```sh
{alice}$ python -c 'from port4me import port4me; print(port4me(user = "bob"))'
54242
```

```sh
{alice}$ python -c 'from port4me import port4me; print(port4me(user = "carol"))'
34307
```

```sh
{alice}$ python -c 'from port4me import port4me; print(port4me("rstudio"))'
22486
```

```sh
{alice}$ python -c 'from port4me import port4me; print(port4me("jupyter-notebook"))'
29525
```


[port4me]: https://github.com/HenrikBengtsson/port4me
