SHELL:=/bin/bash

.PHONY: test

check:
	shellcheck utils/*.sh
