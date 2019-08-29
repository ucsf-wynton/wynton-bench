#! /usr/bin/env bash

error() {
    >&2 echo "ERROR: $*"
    exit 1
}

chdir() {
    cd "$1" || error "Failed to change directory: $1"
}

[[ -z "$TEST_DRIVE" ]] && error "'TEST_DRIVE' not set or empty"

[[ -z "$BENCH_HOME" ]] && error "'BENCH_HOME' not set or empty"

[[ -d "$BENCH_HOME" ]] || error "'BENCH_HOME' is not a directory: $BENCH_HOME"

# Load bench()
# shellcheck disable=SC1090
. "$BENCH_HOME/utils/bench.sh"

opwd=$PWD
chdir "$TEST_DRIVE"

# Create temporary working directory on current drive
tmpdir=$(mktemp --tmpdir="$PWD" --directory .bench.XXXXXX)
chdir "$tmpdir"

# Record the test drive
bench echo "HOSTNAME=$HOSTNAME" > /dev/null
bench echo "TEST_DRIVE=$TEST_DRIVE" > /dev/null
bench echo "PWD=$PWD" > /dev/null

# Benchmark copying a large tarball to current drive
tarball="$BENCH_HOME/test-files/R.tar.gz"
ls -l "$tarball" 
bench cp "$tarball" .

# Benchmark untaring to current drive
bench tar xzf "$(basename "$tarball")"

# Benchmark changing file permissions recursively on current drive
bench chmod -R u+w R/

# Benchmark ls -lR on current drive
bench ls -lR "R/lib*/R/library/base/" > /dev/null

# Benchmark launching Rscript (minimal) that lives on current drive
TMPDIR=. bench R/bin/Rscript --version > /dev/null

# Benchmark launching Rscript that lives on current drive
TMPDIR=. bench R/bin/Rscript --vanilla -e "sessionInfo()" > /dev/null

# Benchmark removing folder on current drive
bench rm -rf R/

# Cleanup
chdir "$opwd"
rm -rf -- "$tmpdir"
