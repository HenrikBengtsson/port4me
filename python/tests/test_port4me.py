from port4me import port4me

def test_alice():
    assert port4me('', 'alice', list=5) == [30845, 19654, 32310, 63992, 15273]

def test_alice_tool():
    assert port4me('jupyter-notebook', 'alice', list=1) == [47467]

def test_alice_prepend():
    assert port4me('', 'alice', list=5, prepend=[9876, 5432]) == [9876, 5432, 30845, 19654, 32310]

def test_bob():
    assert port4me('', 'bob', list=5) == [54242, 4930, 42139, 14723, 55707]

def test_bob_skip_exclude():
    assert port4me('', 'bob', list=2, skip=1, exclude=[54252, 14723]) == [42139, 55707]
