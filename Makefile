SHELL=bash

test: check shellcheck

check:
	(cd bash; make check)
	(cd r; make check)

shellcheck:
	(cd bash; make shellcheck)
