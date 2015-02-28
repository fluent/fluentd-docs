# file Buffer Plugin

The `file` buffer plugin provides a persistent buffer implementation. It uses files to store buffer chunks on disk.

### Example Config

    :::text
    <match pattern>
      buffer_type file
      buffer_path /var/log/fluent/myapp.*.buffer
    </match>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

### Parameters

#### buffer_type (required)
The value must be `file`.

#### buffer_path (required)
The path where buffer chunks are stored. The ‘*’ is replaced with random characters. This parameter is require

This parameter must be unique to avoid race condition problem. For example, you can't use fixed buffer_path parameter in fluent-plugin-forest. `${tag}` or similar placeholder is needed. Of course, this parameter must also be unique between fluentd instances.

#### buffer_chunk_limit
The size of each buffer chunk. The default is 8m. The suffixes “k” (KB), “m” (MB), and “g” (GB) can be used. Please see the [Buffer Plugin Overview](buffer-plugin-overview) article for the basic buffer structure. 

NOTE: The default value for Time Sliced Plugin is overwritten as 256m.

#### buffer_queue_limit
The length limit of the chunk queue. Please see the [Buffer Plugin Overview](buffer-plugin-overview) article for the basic buffer structure. The default limit is 256 chunks.

#### flush_interval
The interval between data flushes. The suffixes “s” (seconds), “m” (minutes), and “h” (hours) can be used

#### flush_at_shutdown
If true, queued chunks are flushed at shutdown process. The default is `false`.

#### retry_wait
The interval between retries. The suffixes “s” (seconds), “m” (minutes), and “h” (hours) can be used.
