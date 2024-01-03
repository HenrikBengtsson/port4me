SHELL=bash
VERSION=0.6.0-
OLD_VERSION=0.6.0

check:
	(cd bash; make check; make shellcheck)
	(cd r; make check; make check-cli)
	(cd python; make check; make check-cli)

install-bash:
	cd bash; make install

install-r:
	cd r; make install

install-python:
	cd python; make install

find_old_version:
	grep --exclude-dir=.git --exclude-dir=.local --include="*" --exclude="*~" --exclude="Makefile" -E "(version|Version|VERSION).*$(OLD_VERSION)" -r

find_version:
	grep --exclude-dir=.git --exclude-dir=.local --include="*" --exclude="*~" --exclude="Makefile" -E "(version|Version|VERSION).*$(VERSION)" -r
