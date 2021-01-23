path <- system.file(package = "wyntonbench", "exdata", mustWork = TRUE)

## Read *all* raw bench log files
raw <- read_all_bench_logs(path)

## Drop all 'echo' entries
raw <- trim_bench_log(raw)
print(raw)

## Focus on benchmark drive /scratch
raw <- subset(raw, drive == "/scratch")

## Get benchmarks for untar:ing a file to the benchmark drive
stats <- extract_bench_log(raw, what = "untar_ram_to_drive")
print(stats)
# # A tibble: 11 x 16
#    timestamp           id      hostname drive    ru_wallclock ru_stime ru_utime
#    <dttm>              <chr>   <chr>    <chr>           <dbl>    <dbl>    <dbl>
#  1 2019-09-03 15:53:04 2K02... qb3-dev3 /scratch         0.41     0.26     0.36
#  2 2019-09-03 16:03:04 80E0... qb3-dev3 /scratch         0.41     0.24     0.35
#  3 2019-09-03 16:13:04 wk1u... qb3-dev3 /scratch         0.37     0.24     0.32
#  4 2019-09-03 16:23:03 GPHl... qb3-dev3 /scratch         0.41     0.26     0.35
#  5 2019-09-03 16:33:04 Ftys... qb3-dev3 /scratch         0.41     0.27     0.35
#  6 2019-09-03 16:43:04 tcrr... qb3-dev3 /scratch         0.4      0.25     0.35
#  7 2019-09-03 16:53:03 3cZH... qb3-dev3 /scratch         0.37     0.22     0.33
#  8 2019-09-03 17:03:04 LFh5... qb3-dev3 /scratch         0.4      0.26     0.35
#  9 2019-09-03 17:13:03 a4zi... qb3-dev3 /scratch         0.41     0.26     0.35
# 10 2019-09-03 17:23:04 sdlt... qb3-dev3 /scratch         0.39     0.25     0.34
# 11 2019-09-03 17:33:04 1kp4... qb3-dev3 /scratch         0.41     0.26     0.35
# # ... with 9 more variables: cpu_pct <dbl>, ru_nvcsw <dbl>, ru_invcsw <dbl>,
# #     ru_inblock <dbl>, ru_outblock <dbl>, ru_maxrss <dbl>, ru_minflt <dbl>,
# #     exit_status <dbl>, command <chr>

## The first benchmark entry
str(stats[1,])
# tibble [1 x 16] (S3: bench_log/tbl_df/tbl/data.frame)
#  $ timestamp   : POSIXct[1:1], format: "2019-09-03 15:53:04"
#  $ id          : chr "2K0293"
#  $ hostname    : chr "qb3-dev3"
#  $ drive       : chr "/scratch"
#  $ ru_wallclock: num 0.41
#  $ ru_stime    : num 0.26
#  $ ru_utime    : num 0.36
#  $ cpu_pct     : num 1.51
#  $ ru_nvcsw    : num 1041
#  $ ru_invcsw   : num 8
#  $ ru_inblock  : num 0
#  $ ru_outblock : num 76408
#  $ ru_maxrss   : num 1180
#  $ ru_minflt   : num 697
#  $ exit_status : num 0
#  $ command     : chr "tar zxf /tmp/.bench.ca1noS/R-2.0.0.tar.gz -C ."
