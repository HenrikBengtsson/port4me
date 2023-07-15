SHELL=bash
VERSION=0.6.0
OLD_VERSION=0.5.1

check:
	(cd bash; make check; make shellcheck)
	(cd r; make check; make check-cli)
	(cd python; make check; make check-cli)

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

find_old_version:
	grep --exclude-dir=.git --include="*" --exclude="*~" --exclude="Makefile" -F "$(OLD_VERSION)" -r

find_version:
	grep --exclude-dir=.git --include="*" --exclude="*~" --exclude="Makefile" -F "$(VERSION)" -r
