from argparse import ArgumentParser
from . import port4me, parse_ports

parser = ArgumentParser(prog="python -m port4me", description="port4me: Get the Same, Personal, Free TCP Port over and over")
parser.add_argument("--tool", type=str, help="Used in the seed when generating port numbers, to get a different port sequence for different tools.")
parser.add_argument("--user", type=str, help="Used in the seed when generating port numbers. Defaults to determining the username with getuser().")
parser.add_argument("--prepend", type=parse_ports, metavar="PORTS", help="A list of ports to try first")
parser.add_argument("--include", type=parse_ports, metavar="PORTS", help="If specified, skip any ports not in this list")
parser.add_argument("--exclude", type=parse_ports, metavar="PORTS", help="Skip any ports in this list")
parser.add_argument("--list", type=int, metavar="N", help="Instead of returning a single port, return a list of this many ports without checking if they are free.")
parser.add_argument("--test", type=int, metavar="PORT", help="If specified, return whether the port `PORT` is not in use. All other parameters will be ignored.")

print(port4me(**vars(parser.parse_args())))
