# Failure Scenarios

This article lists various Fluentd failure scenarios. We will assume that you have configured Fluentd for [High Availability](high-availability), so that each app node has its local *forwarders* and all logs are aggregated into multiple *aggregators*.

## Apps Cannot Post Records to Forwarder
In the failure scenario, the application sometimes fails to post records to its local Fluentd instance when using logger libraries of various languages. Depending on the maturity of each logger library, some clever mechanisms have been implemented to prevent data loss.

#### 1) Memory Buffering (available for [Ruby](ruby), [Java](java), [Python](python), [Perl](perl))
If the destination Fluentd instance dies, certain logger implementations will use extra memory to hold incoming logs. When Fluentd comes back, these loggers will automatically send out the buffered logs to Fluentd again. Once the maximum buffer memory size is reached, most current implementations will write the data onto the disk or throw away the logs.

#### 2) Exponential Backoff (available for [Ruby](ruby), [Java](java))
When trying to resend logs to the local forwarder, some implementations will use exponential backoff to prevent excessive re-connect requests.

## Forwarder or Aggregator Fluentd Goes Down
What happens when a Fluentd process dies for some reason? It depends on your buffer configuration.

#### buf_memory
If you're using [buf_memory](buf_memory), the buffered data is completely lost. This is a tradeoff for higher performance. Lowering the flush_interval will reduce the probability of losing data, but will increase the number of transfers between forwarders and aggregators.

#### buf_file
If you're using [buf_file](buf_file), the buffered data is stored on the disk. After Fluentd recovers, it will try to send the buffered data to the destination again.

Please note that the data will be lost if the buffer file is broken due to I/O errors. The data will also be lost if the disk is full, since there is nowhere to store the data on disk.

## Storage Destination Goes Down
If the storage destination (e.g. Amazon S3, MongoDB, HDFS, etc.) goes down, Fluentd will keep trying to resend the buffered data. The retry logic depends on the plugin implementation.

If you're using [buf_memory](buf_memory), aggregators will stop accepting new logs once they reach their buffer limits. If you're using [buf_file](buf_file), aggregators will continue accepting logs until they run out of disk space.
