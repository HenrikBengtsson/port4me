SHELL=bash

test: shellcheck check

check:
	module load CBI bats-core bats-assert bats-file; \
	(cd tests/; bats *.bats)

shellcheck:
	shellcheck incl/*.bash
	shellcheck -x port4me

install:
	@[[ -n "$$PREFIX" ]] || { >&2 echo "ERROR: Installation folder 'PREFIX' is not set"; exit 1; }
	echo "Installing to folder PREFIX=$$PREFIX"
	mkdir -p "$$PREFIX/bin"
	cp -R {port4me,incl} "$$PREFIX/bin"
	[[ -f "$$PREFIX/bin/port4me" ]]
	[[ -x "$$PREFIX/bin/port4me" ]]

