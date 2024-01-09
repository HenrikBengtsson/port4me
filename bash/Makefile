SHELL=bash

test: shellcheck check

check: check-cli

assert_bats:
	command -v "bats"
	echo "BATS_SUPPORT_HOME=$${BATS_SUPPORT_HOME:?}"
	echo "BATS_ASSERT_HOME=$${BATS_ASSERT_HOME:?}"

check-cli:
	(cd tests/; PATH="..:$${PATH}" PORT4ME_CLI_CALL="port4me" bats *.bats)

shellcheck:
	shellcheck completions/*.bash
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

