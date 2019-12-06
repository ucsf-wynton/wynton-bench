#! /usr/bin/env bash

# shellcheck disable=SC2034
export BENCH_LOGPATH=$HOME/wynton-bench-logs/$HOSTNAME

# Default drives to be tested
TEST_DRIVES=${TEST_DRIVES:-/tmp/$USER /scratch/$USER /wynton/scratch/$USER $HOME /wynton/group/cbi/$USER /netapp/home/$USER}

for dir in ${TEST_DRIVES}; do
    if [[ -d "$dir" ]]; then
        TEST_DRIVE="$dir" "$BENCH_HOME/bench-scripts/bench-files-tarball.sh"
    fi
done
