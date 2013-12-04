# Performance Tuning

## Check top command

If Fluentd doesn't perform as well as you had expected, please check the `top` command first. You need to identify which part of your system is the bottleneck (CPU? Memory? Disk I/O? etc).

## Multi Process

The CPU is often the bottleneck for Fluentd instances that handle billions of incoming records. To utilize multiple CPU cores, we recommend using the `in_multiprocess` plugin.

* [in_multiprocess](in_multiprocess)


