#! /usr/bin/env bash

error() {
    >&2 echo "ERROR: $*"
    exit 1
}

chdir() {
    cd "$1" || error "Failed to change directory: $1"
}

[[ -z "$BENCH_HOME" ]] && error "'BENCH_HOME' not set or empty"
[[ -d "$BENCH_HOME" ]] || error "'BENCH_HOME' is not a directory: $BENCH_HOME"

# Load bench()
# shellcheck disable=SC1090
. "$BENCH_HOME/utils/bench.sh"

BENCH_LOGPATH=${BENCH_LOGPATH:-${PWD}}

[[ -z "$TEST_DRIVE" ]] && error "'TEST_DRIVE' not set or empty"

BENCH_LOGNAME=${BENCH_LOGNAME:-"bench-files-tarball_${TEST_DRIVE//\//_}.log"}
BENCH_LOGFILE=${BENCH_LOGFILE:-"$BENCH_LOGPATH/$BENCH_LOGNAME"}
echo "BENCH_LOGFILE:"
echo "$BENCH_LOGFILE"

opwd=$PWD
chdir "$TEST_DRIVE"

# Create temporary working directory on current drive
tmpdir=$(mktemp --tmpdir="$PWD" --directory .bench.XXXXXX)
chdir "$tmpdir"

# Record session info
bench echo "HOSTNAME=$HOSTNAME" > /dev/null
bench echo "uptime=$(uptime)" > /dev/null
bench echo "PWD=$PWD" > /dev/null
bench echo "TEST_DRIVE=$TEST_DRIVE" > /dev/null

# Benchmark copying a large tarball to current drive
tarball="$BENCH_HOME/test-files/R-2.0.0.tar.gz"
bench cp "$tarball" .

# Benchmark untaring to current drive
bench tar zxf "$(basename "$tarball")"

# Benchmark ls -lR on current drive
bench ls -lR -- R-2.0.0/src/library/base/ > /dev/null

# Benchmark du -b
bench du -sb R-2.0.0/ > /dev/null

# Benchmark changing file permissions recursively on current drive
bench chmod -R o-r R-2.0.0/

# Benchmark removing folder on current drive
bench rm -rf R-2.0.0/

# Cleanup
chdir "$opwd"
rm -rf -- "$tmpdir"
