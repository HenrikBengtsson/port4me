SHELL=bash

all: install test

test:
	pytest

requirements:
	python -m pip install --upgrade pip
	pip install hatch flake8 pytest

install:
	pip install .

lint:
	flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
