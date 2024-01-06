from port4me import port4me
from os import environ

def test_alice():
    environ['_PORT4ME_CHECK_AVAILABLE_PORTS_'] = 'any'
    assert port4me(user='alice') == 30845


def test_alice_env():
    environ['_PORT4ME_CHECK_AVAILABLE_PORTS_'] = 'any'
    environ['PORT4ME_USER'] = 'alice'
    assert port4me('') == 30845
    environ.pop('PORT4ME_USER')
    environ.pop('_PORT4ME_CHECK_AVAILABLE_PORTS_')


def test_alice_list_one():
    assert port4me(user='alice', list=1) == [30845]


def test_alice_list_five():
    assert port4me(user='alice', list=5) == [30845, 19654, 32310, 63992, 15273]


def test_alice_list_five_env():
    environ['PORT4ME_LIST'] = '5'
    assert port4me(user='alice') == [30845, 19654, 32310, 63992, 15273]
    environ.pop('PORT4ME_LIST')


def test_alice_tool():
    environ['_PORT4ME_CHECK_AVAILABLE_PORTS_'] = 'any'
    assert port4me(tool='jupyter-notebook', user='alice') == 29525
    environ.pop('_PORT4ME_CHECK_AVAILABLE_PORTS_')


def test_alice_tool_noname():
    environ['_PORT4ME_CHECK_AVAILABLE_PORTS_'] = 'any'
    assert port4me('jupyter-notebook', user='alice') == 29525
    environ.pop('_PORT4ME_CHECK_AVAILABLE_PORTS_')


def test_alice_tool_env():
    environ['_PORT4ME_CHECK_AVAILABLE_PORTS_'] = 'any'
    environ['PORT4ME_TOOL'] = 'jupyter-notebook'
    assert port4me(user='alice') == 29525
    environ.pop('PORT4ME_TOOL')
    environ.pop('_PORT4ME_CHECK_AVAILABLE_PORTS_')


def test_alice_skip():
    assert port4me(user='alice', list=3, skip=2) == [32310, 63992, 15273]


def test_alice_skip_env():
    environ['PORT4ME_SKIP'] = '2'
    assert port4me(user='alice', list=3) == [32310, 63992, 15273]
    environ.pop('PORT4ME_SKIP')


def test_alice_exclude():
    environ['_PORT4ME_CHECK_AVAILABLE_PORTS_'] = 'any'
    assert port4me(user='alice', exclude=[30845, 32310]) == 19654
    environ.pop('_PORT4ME_CHECK_AVAILABLE_PORTS_')


def test_alice_exclude_env():
    environ['_PORT4ME_CHECK_AVAILABLE_PORTS_'] = 'any'
    environ['PORT4ME_EXCLUDE'] = '30845,32310'
    assert port4me(user='alice') == 19654
    environ.pop('PORT4ME_EXCLUDE')
    environ.pop('_PORT4ME_CHECK_AVAILABLE_PORTS_')


def test_alice_include():
    environ['_PORT4ME_CHECK_AVAILABLE_PORTS_'] = 'any'
    assert port4me(user='alice', include=list(range(2000, 2123+1)) + [4321] + list(range(10000, 10999+1))) == 10451
    environ.pop('_PORT4ME_CHECK_AVAILABLE_PORTS_')


def test_alice_include_str():
    environ['_PORT4ME_CHECK_AVAILABLE_PORTS_'] = 'any'
    assert port4me(user='alice', include="2000-2123,4321,10000-10999") == 10451
    environ.pop('_PORT4ME_CHECK_AVAILABLE_PORTS_')


def test_alice_include_env():
    environ['_PORT4ME_CHECK_AVAILABLE_PORTS_'] = 'any'
    include = list(range(2000, 2123+1)) + [4321] + list(range(10000, 10999+1))
    environ['PORT4ME_INCLUDE'] = ','.join(map(str, include))
    assert port4me(user='alice') == 10451
    environ.pop('PORT4ME_INCLUDE')
    environ.pop('_PORT4ME_CHECK_AVAILABLE_PORTS_')


def test_alice_prepend():
    assert port4me(user='alice', list=5, prepend=[4321, 11001]) == [4321, 11001, 30845, 19654, 32310]


def test_alice_prepend_env():
    environ['PORT4ME_PREPEND'] = '4321,11001'
    assert port4me(user='alice', list=5) == [4321, 11001, 30845, 19654, 32310]
    environ.pop('PORT4ME_PREPEND')


def test_bob():
    assert port4me(user='bob', list=5) == [54242, 4930, 42139, 14723, 55707]


def test_bob_skip_exclude():
    assert port4me(user='bob', list=2, skip=1, exclude=[54242, 14723]) == [42139, 55707]


def test_port_80_is_blocked():
    import platform
    import pytest
    if platform.system() != "Linux":
        pytest.skip("Privileged ports are only blocked on Linux: " + platform.system())
    assert port4me(test=80) == False

def test_port_is_busy():
    import socket
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(("", 0))  ## 0 = ask operating system for a free, random port
    addr, port = s.getsockname()
    assert port4me(test=port) == False
    s.close()
