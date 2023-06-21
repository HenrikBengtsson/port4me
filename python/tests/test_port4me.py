from port4me import port4me

def test_alice():
    assert port4me('', 'alice') == 30845


def test_alice():
    assert port4me('', 'alice', list=1) == [30845]

    
def test_alice():
    assert port4me('', 'alice', list=5) == [30845, 19654, 32310, 63992, 15273]


def test_alice_tool():
    assert port4me('jupyter-notebook', 'alice', list=1) == [29525]


def test_alice_exclude():
    assert port4me('', 'alice', exclude=[30845, 32310]) == 19654

   
def test_alice_exclude():
    assert port4me('', 'alice', include=list(range(2000, 2123+1)) + [4321] + list(range(10000, 10999+1))) == 10451


def test_alice_prepend():
    assert port4me('', 'alice', list=5, prepend=[4321, 11001]) == [4321, 11001, 30845, 19654, 32310]


def test_bob():
    assert port4me('', 'bob', list=5) == [54242, 4930, 42139, 14723, 55707]


def test_bob_skip_exclude():
    assert port4me('', 'bob', list=2, skip=1, exclude=[54242, 14723]) == [42139, 55707]
