from port4me import uint_hash


def test_empty():
    assert uint_hash('') == 0


def test_A():
    assert uint_hash('A') == 65


def test_alice():
    assert uint_hash('alice,rstudio') == 3688618396


def test_long():
    assert uint_hash('port4me - get the same, personal, free TCP port over and over') == 1731535982
