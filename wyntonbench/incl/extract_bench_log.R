path <- system.file(package = "wyntonbench", "exdata", mustWork = TRUE)

## Read *all* raw bench log files
raw <- read_all_bench_logs(path)
trimmed <- trim_bench_log(raw)
print(trimmed)

## Extract a few types of stats
stats <- extract_bench_log(trimmed, what = "cp_file_source_to_ram")
print(stats)

stats <- extract_bench_log(trimmed, what = "untar_ram_to_drive")
print(stats)
