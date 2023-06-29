SHELL=bash

test: shellcheck check

check:
	(cd bash; make check)
	(cd r; make check)
	(cd python; make check)

shellcheck:
	(cd bash; make shellcheck)

install-bash:
	@[[ -n "$$PREFIX" ]] || { >&2 echo "ERROR: Installation folder 'PREFIX' is not set"; exit 1; }
	echo "Installing to folder PREFIX=$$PREFIX"
	mkdir -p "$$PREFIX/bin"
	cp -R bash/{port4me,incl} "$$PREFIX/bin"
	[[ -f "$$PREFIX/bin/port4me" ]]
	[[ -x "$$PREFIX/bin/port4me" ]]

install-r:
	cd r; make install

install-python:
	cd python; make install
