#!/usr/bin/env python
# -*- coding: utf-8 -*-

from itertools import islice
import socket
from getpass import getuser
from os import getenv


__all__ = ['port4me']


# Source: https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc
# Last updated: 2022-10-24
unsafe_ports_chrome = getenv("PORT4ME_EXCLUDE_UNSAFE_CHROME")
if unsafe_ports_chrome:
    unsafe_ports_chrome = set(map(int, unsafe_ports_chrome.split(',')))
else:
    unsafe_ports_chrome = {1,7,9,11,13,15,17,19,20,21,22,23,25,37,42,43,53,69,77,79,87,95,101,102,103,104,109,110,111,113,115,117,119,123,135,137,139,143,161,179,389,427,465,512,513,514,515,526,530,531,532,540,548,554,556,563,587,601,636,989,990,993,995,1719,1720,1723,2049,3659,4045,5060,5061,6000,6566,6665,6666,6667,6668,6669,6697,10080}

# Source: https://www-archive.mozilla.org/projects/netlib/portbanning#portlist
# Last updated: 2022-10-24
unsafe_ports_firefox = getenv("PORT4ME_EXCLUDE_UNSAFE_FIREFOX")
if unsafe_ports_firefox:
    unsafe_ports_firefox = set(map(int, unsafe_ports_firefox.split(',')))
else:
    unsafe_ports_firefox = {1,7,9,11,13,15,17,19,20,21,22,23,25,37,42,43,53,77,79,87,95,101,102,103,104,109,110,111,113,115,117,119,123,135,139,143,179,389,465,512,513,514,515,526,530,531,532,540,556,563,587,601,636,993,995,2049,4045,6000}


def uint_hash(s):
    h = 0
    for char in s:
        h = (31 * h + ord(char)) % 2**32 
    return h


def is_port_free(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return (s.connect_ex(('', port)) != 0)


def lcg(seed, a=75, c=74, modulus=65537):
    """
    Get the next number in a sequence according to a Linear Congruential Generator algorithm.

    The default constants are from the ZX81.
    """
    seed %= modulus
    seed_next = (a*seed + c) % modulus

    # For certain LCG parameter settings, we might end up in the same
    # LCG state. For example, this can happen when (a-c) = 1 and
    # seed = modulus-1. To make sure we handle any parameter setup, we
    # detect this manually, increment the seed, and recalculate.
    if seed_next == seed:
        return lcg(seed+1, a, c, modulus)

    #assert 0 <= seed_next <= modulus
    return seed_next


def port4me_gen_unfiltered(tool='', user='', prepend=None):
    if prepend is None:
        prepend = [int(p) for p in getenv("PORT4ME_PREPEND", "").split(",") if p]
        prepend.extend(int(p) for p in getenv("PORT4ME_PREPEND_SITE", "").split(",") if p and p not in prepend)

    yield from prepend

    if not user: user = getuser()

    port = uint_hash((user+','+tool).rstrip(','))
    while True:
        port = lcg(port)
        yield port


def port4me_gen(tool='', user='', prepend=None, whitelist=None, blacklist=None, min_port=1024, max_port=65535, chrome_safe=True, firefox_safe=True):
    for port in port4me_gen_unfiltered(tool, user, prepend):
        if ((min_port <= port <= max_port)
            and (not whitelist or port in whitelist)
            and (not blacklist or port not in blacklist)
            and (not chrome_safe or port not in unsafe_ports_chrome)
            and (not firefox_safe or port not in unsafe_ports_firefox)):
                yield port


_list = list  # necessary to avoid conflicts with list() and the parameter which is named list
def port4me(tool='', user='', prepend=None, whitelist=None, blacklist=None, skip=0, list=0, test=None, max_tries=65536, must_work=True, min_port=1024, max_port=65535, chrome_safe=True, firefox_safe=True):
    """
    Find a free TCP port using a deterministic sequence of ports based on the current username.

    This reduces the chance of different users trying to access the same port,
    without having to use a completely random new port every time.

    Parameters
    ----------
    tool : str, optional
        Used in the seed when generating port numbers, to get a different port sequence for different tools.
    user : str, optional
        Used in the seed when generating port numbers. Defaults to determining the username with getuser().
    prepend : list, optional
        A list of ports to try first
    whitelist : list, optional
        If specified, skip any ports not in this list
    blacklist : list, optional
        Skip any ports in this list
    skip : int, optional
        Skip this many ports at the beginning (after excluded ports have been skipped)
    list : int, optional
        Instead of returning a single port, return a list of this many ports without checking if they are free.
    test : int, optional
        If specified, return whether the port `test` is not in use. All other parameters will be ignored.
    max_tries : int, optional
        Raise a TimeoutError if it takes more than this many tries to find a port. Default is 65536.
    must_work : bool, optional
        If True, then an error is produced if no port could be found. If False, then `-1` is returned.
    min_port : int, optional
        Skips any ports that are smaller than this
    max_port : int, optional
        Skips any ports that are larger than this
    chrome_safe : bool, optional
        Whether to skip ports that Chrome refuses to open
    firefox_safe : bool, optional
        Whether to skip ports that Firefox refuses to open

    See Also
    --------
    `unsafe_ports_chrome` : set of ports to be skipped when `chrome_safe=True`
    `unsafe_ports_firefox` : set of ports to be skipped when `firefox_safe=True`
    """
    if test:
        return is_port_free(test)

    tries = 1

    gen = port4me_gen(tool, user, prepend, whitelist, blacklist, min_port, max_port, chrome_safe, firefox_safe)

    if skip:
        for port in gen:
            tries += 1
            if tries > skip:
                break

    if list:
        return _list(islice(gen, list))

    for port in gen:
        if is_port_free(port):
            break

        if max_tries and tries > max_tries:
            if must_work:
                raise TimeoutError("Failed to find a free TCP port after {} attempts".format(max_tries))
            else:
                return -1

        tries += 1

    return port


if __name__ == '__main__':
    print(port4me(user='alice'))
    print(port4me('rstudio', user='alice'))
    print(port4me('jupyter-notebook', user='alice'))  # gets incorrect result
    print(port4me(user='bob'))
