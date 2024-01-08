#! /usr/bin/env bash

# --------------------------------------------------------------------
# Initialize
# --------------------------------------------------------------------
error() {
    >&2 echo "ERROR: $*"
    exit 1
}

debug() {
    ${BENCH_DEBUG:-false} || return
    >&2 echo "DEBUG: $*"
}

chdir() {
    cd "$1" || error "Failed to change directory: $1"
}

makedir() {
    debug "makedir('$1')"
    mkdir -p "$1" || error "Failed to create directory: $1"
}

[[ -z "$BENCH_HOME" ]] && error "'BENCH_HOME' not set or empty"
[[ -d "$BENCH_HOME" ]] || error "'BENCH_HOME' is not a directory: $BENCH_HOME"

# Load bench()
# shellcheck disable=SC1090
. "$BENCH_HOME/utils/bench.sh"


# --------------------------------------------------------------------
# Setup benchmark environment
# --------------------------------------------------------------------
debug "BASH_SOURCE=${BASH_SOURCE:?}"
BASH_SOURCE_NAME="$(basename "${BASH_SOURCE:?}")"
BASH_SOURCE_NAME="${BASH_SOURCE_NAME%.*}"
debug "BENCH_SOURCE_NAME=${BENCH_SOURCE_NAME:?}"

BENCH_LOGPATH=${BENCH_LOGPATH:-"${PWD}/.wynton-bench"}
debug "BENCH_LOGPATH=$BENCH_LOGPATH"
makedir "$BENCH_LOGPATH"

RAMTMPDIR=${RAMTMPDIR:-/tmp/$USER}
debug "RAMTMPDIR=$RAMTMPDIR"
makedir "$RAMTMPDIR"

debug "TEST_DRIVE=$TEST_DRIVE"
[[ -z "$TEST_DRIVE" ]] && error "'TEST_DRIVE' not set or empty"

## Backward compatibility
## https://github.com/ucsf-wynton/wynton-bench/issues/11
if [[ -z "$BENCH_LOGNAME" ]] && [[ -z "$BENCH_LOGFILE" ]]; then
  BENCH_LOGNAME="${BASH_SOURCE_NAME}_${TEST_DRIVE//\//_}.log"
  BENCH_LOGFILE="$BENCH_LOGPATH/$BENCH_LOGNAME"
  if [[ ! -f "$BENCH_LOGFILE" ]]; then
    BENCH_LOGNAME=
    BENCH_LOGFILE=
  fi
fi

BENCH_LOGNAME=${BENCH_LOGNAME:-"${BASH_SOURCE_NAME}_${TEST_DRIVE//\//_}.tsv"}
BENCH_LOGFILE=${BENCH_LOGFILE:-"$BENCH_LOGPATH/$BENCH_LOGNAME"}

echo "BENCH_LOGFILE: '$BENCH_LOGFILE'"

## Append to log file atomically
BENCH_LOGFILE_FINAL=$BENCH_LOGFILE

BENCH_LOGFILE=$(mktemp --tmpdir="$RAMTMPDIR" BENCH_LOGFILE.XXXXXX)
echo "BENCH_LOGFILE (temporary): '$BENCH_LOGFILE'"

debug "PWD=$PWD"
opwd=$PWD
chdir "$TEST_DRIVE"

makedir "$PWD/.wynton-bench"
makedir "$RAMTMPDIR/.wynton-bench"

# Create temporary working directory on drive reciding in memory,
# which typically is /tmp
tmpdir=$(mktemp --tmpdir="$RAMTMPDIR/.wynton-bench" --directory .bench.XXXXXX)

# Create temporary working directory on current drive
workdir=$(mktemp --tmpdir="$PWD/.wynton-bench" --directory .bench.XXXXXX)
chdir "$workdir"

# Record start time
t_begin=$(date "+%s%N")

# Record session info
bench echo "HOSTNAME=$HOSTNAME" > /dev/null
bench echo "uptime=$(uptime)" > /dev/null
bench echo "PWD=$PWD" > /dev/null
bench echo "TEST_DRIVE=$TEST_DRIVE" > /dev/null


# --------------------------------------------------------------------
# Run benchmark tests
# --------------------------------------------------------------------

# Benchmark copying a large tarball to RAM temporary drive
# Comment: Over a long time, this will give us relative stats on
# the performance on the RAM temporary drive on the local machine
tarball="R-2.0.0.tar.gz"
tarball_path="$BENCH_HOME/test-files"
bench cp "$tarball_path/$tarball" "$tmpdir"

# Benchmark copying tarball to current drive, e.g. /tmp -> /scratch
bench cp "$tmpdir/$tarball" .
rm -- "$tmpdir/$tarball"  ## Not needed anymore

# Benchmark copying tarball from current drive, e.g. /scratch -> /tmp
bench cp "$tarball" "$tmpdir"

# Benchmark remove tarball from current drive, e.g. rm /scratch
bench rm -- "$tarball"

# Benchmark untar:ing to current drive, e.g. /tmp/a.tar.gz -> /scratch
bench tar zxf "$tmpdir/$tarball" -C .

# Benchmark ls -lR on current drive
bench ls -lR -- R-2.0.0/src/library/ > /dev/null

# Benchmark finding file current drive
bench find R-2.0.0/ -type f -name Rconnections.h > /dev/null

# Benchmark du -b
bench du -sb R-2.0.0/ > /dev/null

# Benchmark changing file permissions recursively on current drive
bench chmod -R o-r R-2.0.0/

# Benchmark tar:ing from current drive, e.g. /scratch -> /tmp/a.tar
bench tar cf "$tmpdir/foo.tar" R-2.0.0
rm -- "$tmpdir/foo.tar"  ## Not needed anymore

# Benchmark tar:ing on current drive, e.g. /scratch -> /scratch/a.tar
bench tar cf "foo.tar" R-2.0.0

# Benchmark gzip:ing on current drive, e.g. /scratch -> /scratch/
bench gzip "foo.tar"

# Benchmark removing folder on current drive
bench rm -rf R-2.0.0/

# Record end time
t_end=$(date "+%s%N")

# Output total benchmakr time (in seconds)
t_delta=$(bc <<<"scale=3; ($t_end - $t_begin) / 1000000000")
bench echo "total_time=$t_delta seconds" > /dev/null



# --------------------------------------------------------------------
# Record benchmark results
# --------------------------------------------------------------------
# Cleanup
chdir "$opwd"
rm -rf -- "$workdir"
rm -rf -- "$tmpdir"

# Append all collected output
cat "$BENCH_LOGFILE" >> "$BENCH_LOGFILE_FINAL"
rm -- "$BENCH_LOGFILE"

