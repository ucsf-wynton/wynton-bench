#! /usr/bin/env bash

## Sanity checks
[[ -z "$HOME" ]] && { 1>&2 echo "ERROR: Environment variable not set: HOME"; exit 1; }
[[ -z "$HOSTNAME" ]] && { 1>&2 echo "ERROR: Environment variable not set: HOSTNAME"; exit 1; }
[[ -z "$USER" ]] && { 1>&2 echo "ERROR: Environment variable not set: USER"; exit 1; }
[[ -z "$BENCH_HOME" ]] && { 1>&2 echo "ERROR: Environment variable not set: BENCH_HOME"; exit 1; }

# shellcheck disable=SC2034
export BENCH_LOGPATH=$HOME/wynton-bench-logs/$HOSTNAME

# Default drives to be tested
TEST_DRIVES=${TEST_DRIVES:-/tmp/$USER /scratch/$USER /wynton/scratch/$USER $HOME /wynton/group/cbi/$USER}

for dir in ${TEST_DRIVES}; do
    if [[ -d "$dir" ]]; then
        TEST_DRIVE="$dir" "$BENCH_HOME/bench-scripts/bench-files-tarball.sh"
    fi
done
