SHELL=bash
VERSION=0.6.0-
OLD_VERSION=0.6.0

check: check-cli
	(cd bash; make check)
	(cd python; make check)
	(cd r; make check)

check-cli:
	(cd bash; make shellcheck)
	(cd python; make check-cli)
	(cd r; make check-cli)

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
