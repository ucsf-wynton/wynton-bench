SHELL:=/bin/bash

R_HOME=$(shell dirname $$(dirname $$(type -p R)))

debug:
	@echo R_HOME=$(R_HOME)

.PHONY: test

test-files: test-files/R.tar.gz

test-files/R.tar.gz:
	mkdir -p test-files
	ln -fs "$(R_HOME)" R
	tar --dereference -v -c -z -f "$@" R
	rm R
	ls -l "$@"

check:
	shellcheck utils/*.sh
