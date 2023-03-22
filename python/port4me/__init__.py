#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
from getpass import getuser
from os import getenv


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
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    return (s.connect_ex(('', port)) != 0)


def LCG(seed, a=75, c=74, modulus=65537):  # constants from the ZX81's algorithm
    seed %= modulus
    seed_next = (a*seed + c) % modulus

    # For certain LCG parameter settings, we might end up in the same
    # LCG state. For example, this can happen when (a-c) = 1 and
    # seed = modulus-1. To make sure we handle any parameter setup, we
    # detect this manually, increment the seed, and recalculate.
    if seed_next == seed:
        return LCG(seed+1, a, c, modulus)

    #assert 0 <= seed_next <= modulus
    return seed_next


def port4me(user='', tool='', min_port=1024, max_port=65535, chrome_safe=True, firefox_safe=True):
    if not user: user = getuser()

    port = uint_hash((user+','+tool).rstrip(','))

    while (not ((min_port <= port <= max_port) and is_port_free(port))
           or (chrome_safe and port in unsafe_ports_chrome)
           or (firefox_safe and port in unsafe_ports_firefox)):
        port = LCG(port)
    
    return port


if __name__ == '__main__':
    print(port4me('alice'))
    print(port4me('alice', 'rstudio'))
    print(port4me('alice', 'jupyter-notebook'))  # gets incorrect result
    print(port4me('bob'))
