# wynton-bench: Benchmarking Tools for the UCSF Wynton HPC Environment

[![Build Status](https://travis-ci.org/UCSF-HPC/wynton-bench.svg?branch=master)](https://travis-ci.org/UCSF-HPC/wynton-bench)


## Low-level file-system benchmarking

At its core, this file-system benchmarking tool runs the system's `time` command(\*) to profile different file processing commands.  See `man time` for details on this command and [utils/bench.sh](https://github.com/ucsf-wynton/wynton-bench/blob/master/utils/bench.sh) for what is probed in each call.

(\*) Note, there is also a `time` in Bash, which is not the same.


### Setup (once)

```sh
$ git clone https://github.com/ucsf-wynton/wynton-bench.git
$ cd wynton-bench
$ make test-files  ## Download test tarball
```

### Run one benchmark round

To run a single benchmark round on a set of predefined target test drives, do:

```sh
$ cd wynton-bench
$ export BENCH_HOME=$PWD
$ $BENCH_HOME/cron-scripts/bench-files-tarball.sh
```

This outputs:

```
BENCH_LOGFILE: '/wynton/home/boblab/alice/wynton-bench-logs/dev3/bench-files-tarball__tmp_alice.log'
BENCH_LOGFILE (temporary): '/tmp/alice/BENCH_LOGFILE.hTTRSZ'
BENCH_LOGFILE: '/wynton/home/boblab/alice/wynton-bench-logs/dev3/bench-files-tarball__wynton_home_boblab_alice.log'
BENCH_LOGFILE (temporary): '/tmp/alice/BENCH_LOGFILE.lpJ8F3'
```

The raw benchmark results are appended to tab-delimited files in `~/wynton-bench-logs/$HOSTNAME/`;

```sh
$ ls -lrt ~/wynton-bench-logs/$HOSTNAME/
total 30
-rw-r--r--. 1 alice lsd  7091 Feb  2 15:52 bench-files-tarball__tmp_alice.log
-rw-r--r--. 1 alice lsd 22866 Feb  2 15:52 bench-files-tarball__wynton_home_boblab_alice.log
```


### Run as a cron job

To profile the file-system performance on a regular basis, log into the host from where you want to run the benchmarks and pre-create the following folder:

```sh
mkdir -p ".crontab/${HOSTNAME}/logs"
```

then add the following to its `crontab`:

```
BENCH_HOME=/wynton/home/boblab/alice/wynton-bench

## Every 10 minutes
*/10 * * * * { flock -xn /tmp/${USER}_bench-files-tarball.sh.lock $BENCH_HOME/cron-scripts/bench-files-tarball.sh; } >> .crontab/${HOSTNAME}/logs/bench_files_tarball.log 2>&1
```
