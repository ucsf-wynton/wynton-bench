#! /usr/bin/env bash

## Sanity checks
[[ -z "$HOME" ]] && { 1>&2 echo "ERROR: Environment variable not set: HOME"; exit 1; }
[[ -z "$HOSTNAME" ]] && { 1>&2 echo "ERROR: Environment variable not set: HOSTNAME"; exit 1; }
[[ -z "$USER" ]] && { 1>&2 echo "ERROR: Environment variable not set: USER"; exit 1; }

host=${host:-$HOSTNAME}

# shellcheck disable=SC2034
export BENCH_LOGPATH=$HOME/wynton-bench-logs/$host

# Default drives to be tested
TEST_DRIVES=${TEST_DRIVES:-/wynton/scratch/$USER $HOME /wynton/group/cbi/$USER}

for dir in ${TEST_DRIVES}; do
    drive="${dir//\//_}"
    src="${BENCH_LOGPATH}/bench-files-tarball_${drive}.tsv"
    dst="wynton-bench_${drive}.tsv"
    if [[ -f "$src" ]]; then
        echo "[INFO] Processing ${src}"
        printf "timestamp\tduration\n" > "$dst"
        grep total_time= "$src" | cut -d $'\t' -f 1,21 | sed -E 's/(echo total_time=| seconds)//g' >> "$dst"
    fi
done
