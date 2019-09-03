#! /usr/bin/env bash
##############################################################################
## LOAD:
## . utils/bench.sh
##
## USAGE:
## bench <command>
##
## EXAMPLES:
##
## DETAILS:
## bench() uses 'time' with the following '--format="..."' flags:
##
## %e ru_wallclock  Elapsed real (wall clock) time used by the process, in seconds.
## %S ru_stime      Total number of CPU-seconds used by the system on behalf of the process (in kernel mode), in seconds.
## %U ru_utime      Total number of CPU-seconds that the process used directly (in user mode), in seconds.
## %P cpu_pct       Percentage of the CPU that this job got.  This is just user + system times divided by the total running time.  It also prints a percentage sign.
## 
## %w ru_nvcsw      Number of times that the program was context-switched voluntarily, for instance while waiting for an I/O operation to complete.
## %c ru_nivcsw     Number of times the process was context-switched involuntarily (because the time slice expired).
## 
## %I ru_inblock    Number of file system inputs by the process.
## %O ru_oublock    Number of file system outputs by the process.
## 
## %r ru_msgrcv     Number of socket messages received by the process.
## %s ru_msgsnd     Number of socket messages sent by the process.
## 
## %k ru_nsignals   Number of signals delivered to the process.
## 
## %M ru_maxrss     Maximum resident set size of the process during its lifetime, in Kilobytes.
## %t ru_avgrss     Average resident set size of the process, in Kilobytes.
## %W ru_nswap      Number of times the process was swapped out of main memory.
##
## %F ru_majflt     Number of major, or I/O-requiring, page faults that occurred while the process was running.  These are faults where the page has actually migrated out of primary memory.
## %R ru_minflt     Number of minor, or recoverable, page faults.  These are pages that are not valid (so they fault) but which have not
##
## %x exit_status   Exit status of the command.
## %C command       Name and command line arguments of the command being timed.
##
##
## %K ru_?????      Average total (data+stack+text) memory use of the process, in Kilobytes.
## 
## %X ru_??rss      Average amount of shared text in the process, in Kilobytes.
## %D ru_?drss      Average size of the process's unshared data area, in Kilobytes.
## %p ru_?srss      Average unshared stack size of the process, in Kilobytes.
##
## %Z ru_?????      System's page size, in bytes.  This is a per-system constant, but varies between systems.
##############################################################################

## Constants
RAMTMPDIR=${RAMTMPDIR:-/tmp}
BENCH_TIME=$(type -P time)
BENCH_TIME_OPTS="--quiet"
BENCH_TIME_OPTS=
BENCH_FORMAT="%e\t%S\t%U\t%P\t%w\t%c\t%I\t%O\t%r\t%s\t%k\t%M\t%t\t%W\t%F\t%R\t%x\t%C"
BENCH_FORMAT_HEADER="ru_wallclock\tru_stime\tru_utime\tcpu_pct\tru_nvcsw\tru_invcsw\t\tru_inblock\tru_outblock\tru_msgrcv\tru_msgsnd\tru_nsignals\tru_maxrss\tru_avgrss\tru_nswap\tru_majflt\tru_minflt\texit_status\tcommand"

bench_header() {
    # shellcheck disable=SC2059
    printf "timestamp\tid\thostname\t$BENCH_FORMAT_HEADER\n"
}    

bench() {
    local outfile
    outfile=$(mktemp --tmpdir="$RAMTMPDIR")

    BENCH_ID=${BENCH_ID:-${BENCH_LOGFILE##*.}}

    { printf "%s\t%s\t%s\t" "$(date --rfc-3339=seconds)" "$BENCH_ID" "$HOSTNAME"; } >> "$outfile"
    "$BENCH_TIME" --output="$outfile" --append $BENCH_TIME_OPTS --format "$BENCH_FORMAT" "$@"

    if [[ -n "$BENCH_LOGFILE" ]]; then
        cat "$outfile" >> "$BENCH_LOGFILE"
    else
	>&2 cat "$outfile"
    fi
    
    rm "$outfile"
}
