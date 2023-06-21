SHELL=bash

all: install test

test:
	pytest

install-req:
	python -m pip install --upgrade pip
	pip install flake8 pytest

install: install-req
	pip install .


