SHELL=bash

test: check shellcheck

check:
	(cd bash; make check)
	(cd r; make check)

shellcheck:
	(cd bash; make shellcheck)

install:
	@[[ -n "$$PREFIX" ]] || >&2 echo "ERROR: Installation folder 'PREFIX' is not set"
	mkdir -p "$$PREFIX/bin"
	cp -R bash/{port4me,incl} "$$PREFIX/bin"

