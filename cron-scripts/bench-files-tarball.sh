#! /usr/bin/env bash

# shellcheck disable=SC2034
export BENCH_LOGPATH=$HOME/wynton-bench-logs/$HOSTNAME

# Default drives to be tested
TEST_DRIVES=${TEST_DRIVES:-/tmp /scratch /wynton/scratch $HOME /wynton/group/cbi /netapp/home/$USER}

for dir in ${TEST_DRIVES}; do
    TEST_DRIVE="$dir" "$BENCH_HOME/bench-scripts/bench-files-tarball.sh"
done
