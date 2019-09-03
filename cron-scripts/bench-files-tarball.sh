#! /usr/bin/env bash

# shellcheck disable=SC2034
export BENCH_LOGPATH=$HOME/wynton-bench-logs/$HOSTNAME

for dir in /tmp /scratch /wynton/scratch $HOME /wynton/group/cbi /netapp/home/$USER; do
    TEST_DRIVE="$dir" "$BENCH_HOME/bench-scripts/bench-files-tarball.sh"
done
