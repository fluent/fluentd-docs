# Fluentd's Signal Handling

This article explains how `Fluentd` handles UNIX signals.

## Process Model

When you launch Fluentd, it creates two processes: supervisor and worker. The supervisor process controls the life cycle of the worker process. Please make sure to send any signals to the supervisor process.

## Signals

### SIGINT or SIGTERM

Stops the daemon gracefully. Fluentd will try to flush the entire memory buffer at once, but will not retry if the flush fails. Fluentd will not flush the file buffer; the logs are persisted on the disk by default.

### SIGUSR1

Forces the buffered messages to be flushed and reopens Fluentd's log. Fluentd will try to flush the current buffer (both memory and file) immediately, and keep flushing at `flush_interval`.

### SIGHUP

Reloads the configuration file by gracefully restarting the worker process. Fluentd will try to flush the entire memory buffer at once, but will not retry if the flush fails. Fluentd will not flush the file buffer; the logs are persisted on the disk by default.
