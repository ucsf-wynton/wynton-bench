SHELL:=/bin/bash

R_HOME=$(shell dirname $$(dirname $$(type -p R)))

debug:
	@echo R_HOME=$(R_HOME)

.PHONY: test

test-files: test-files/R.tar.gz

test-files/R.tar.gz:
	mkdir -p test-files
	cp -pR "$(R_HOME)" R
	find R -type f -exec sed -i -e "s|$(R_HOME)|{{R_HOME}}/R|g" {} \;
	tar czf "$@" R
	chmod -R u+w R
	rm -rf R
	ls -l "$@"

check:
	shellcheck utils/*.sh
	shellcheck -x bench-scripts/*.sh
