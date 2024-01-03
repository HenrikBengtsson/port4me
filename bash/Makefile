SHELL=bash

test: shellcheck check

check: check-cli

check-cli:
	module load CBI bats-core bats-assert bats-file; \
	(cd tests/; PATH="..:$${PATH}" bats *.bats)

shellcheck:
	shellcheck incl/*.bash
	shellcheck port4me
	(cd tests; shellcheck -x *.bats)

install:
	@[[ -n "$$PREFIX" ]] || { >&2 echo "ERROR: Installation folder 'PREFIX' is not set"; exit 1; }
	echo "Installing to folder PREFIX=$$PREFIX"
	mkdir -p "$$PREFIX/bin"
	cp -R {port4me,incl} "$$PREFIX/bin"
	[[ -f "$$PREFIX/bin/port4me" ]]
	[[ -x "$$PREFIX/bin/port4me" ]]

