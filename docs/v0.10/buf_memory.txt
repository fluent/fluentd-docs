# memory Buffer Plugin

The `memory` buffer plugin provides a fast buffer implementation. It uses memory to store buffer chunks. When Fluentd is shut down, buffered logs that can’t be written quickly are deleted.

### Example Config

    :::text
    <match pattern>
      buffer_type memory
    </match>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

### Parameters

#### buffer_type (required)
The value must be `memory`.

#### buffer_chunk_limit
The size of each buffer chunk. The default is 8m. The suffixes “k” (KB), “m” (MB), and “g” (GB) can be used. Please see the [Buffer Plugin Overview](buffer-plugin-overview) article for the basic buffer structure. 

#### buffer_queue_limit
The length limit of the chunk queue. Please see the [Buffer Plugin Overview](buffer-plugin-overview) article for the basic buffer structure. The default limit is 64 chunks.

#### flush_interval
The interval between data flushes. The suffixes “s” (seconds), “m” (minutes), and “h” (hours) can be used

#### flush_at_shutdown
If true, queued chunks are flushed at shutdown process. The default is `true`.
If false, queued chunks are discarded unlike `buf_file`.

#### retry_wait
The interval between retries. The suffixes “s” (seconds), “m” (minutes), and “h” (hours) can be used.
