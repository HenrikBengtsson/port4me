SHELL=bash

test: shellcheck check

check:
	module load CBI bats-core bats-assert bats-file; \
	(cd tests/; bats *.bats)

shellcheck:
	shellcheck incl/*.bash
	shellcheck -x port4me

