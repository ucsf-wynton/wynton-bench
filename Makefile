SHELL:=/bin/bash

R_HOME=$(shell dirname $$(dirname $$(type -p R)))
R_VERSION=
debug:
	@echo R_HOME=$(R_HOME)

.PHONY: test

test-files: test-files/R-2.0.0.tar.gz

## A 10 MB file
test-files/R-2.0.0.tar.gz:
	cd $(@D);\
	curl -O https://cloud.r-project.org/src/base/R-2/R-2.0.0.tar.gz

## A 30 MB file
test-files/R-3.6.1.tar.gz:
	cd $(@D);\
	curl -O https://cloud.r-project.org/src/base/R-3/R-3.6.1.tar.gz
check:
	shellcheck utils/*.sh
	shellcheck -x cron-scripts/*.sh
	shellcheck -x bench-scripts/*.sh
