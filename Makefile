SHELL:=/bin/bash

.PHONY: test

test-files: test-files/R-2.0.0.tar.gz

## A 10 MB file
test-files/R-2.0.0.tar.gz:
	mkdir -p "$(@D)"
	cd "$(@D)";\
	curl -O https://cloud.r-project.org/src/base/R-2/R-2.0.0.tar.gz

## A 30 MB file
test-files/R-3.6.1.tar.gz:
	mkdir -p "$(@D)"
	cd "$(@D)";\
	curl -O https://cloud.r-project.org/src/base/R-3/R-3.6.1.tar.gz

check:
	shellcheck bin/wynton-bench
	shellcheck utils/*.sh
	shellcheck -x cron-scripts/*.sh
	shellcheck -x bench-scripts/*.sh

test: test-files/R-2.0.0.tar.gz
	TEST_DRIVE=$(PWD) BENCH_HOME=$(PWD) bench-scripts/bench-files-tarball.sh

