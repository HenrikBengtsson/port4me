SHELL=bash

all: install test

check:
	pytest

check-cli:
	module load CBI bats-core bats-assert bats-file; \
	(cd tests/; bats *.bats)

requirements:
	python -m pip install --upgrade pip
	pip install hatch flake8 pytest

install:
	pip install .

lint:
	flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

coverage:
	python -m pytest --cov=port4me/

coverage-html:
	pytest --cov=port4me/ --cov-report=html; xdg-open htmlcov/index.html

cleanup:
	find . -type d -name "__pycache__" -exec rm -rf {} + || true
	[[ -d .pytest_cache ]] && rm -rf .pytest_cache || true
	[[ -f .coverage  ]] && rm .coverage || true
	[[ -f .coverage.xml  ]] && rm .coverage.xml || true
	[[ -d htmlcov ]] && rm -rf htmlcov || true

pypi-build:
	pip install build twine
	rm -rf dist/
	python3 -m build --sdist

pypi-upload: dist/port4me-*.tar.gz
	python3 -m twine upload --user __token__ dist/port4me-*.tar.gz
