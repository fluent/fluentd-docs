# Buffer Plugin Overview

Fluentd has 6 types of plugins: [Input](input-plugin-overview), [Parser](parser-plugin-overview), [Filter](filter-plugin-overview), [Output](output-plugin-overview), [Formatter](formatter-plugin-overview) and [Buffer](buffer-plugin-overview). This article gives an overview of Filter Plugin.

We will first explain how Buffer Plugin works in general. Then, we will explain the mechanism of Time Sliced Plugin, a subclass of Buffer Plugin used by several core plugins. 

## Buffer Plugin Overview

Buffer plugins are used by buffered output plugins, such as `out_file`, `out_forward`, etc. Users can choose the buffer plugin that best suits their performance and reliability needs.

## Buffer Structure

The buffer structure is a queue of chunks like the following:

    :::text
    queue
    +---------+
    |         |
    |  chunk <-- write events to the top chunk
    |         |
    |  chunk  |
    |         |
    |  chunk  |
    |         |
    |  chunk --> write out the bottom chunk
    |         |
    +---------+

When the top chunk exceeds the specified size or time limit (`buffer_chunk_limit` and `flush_interval`, respectively), a new empty chunk is pushed to the top of the queue. The bottom chunk is written out immediately when new chunk is pushed.

If the bottom chunk write out fails, it will remain in the queue and Fluentd will retry after waiting several seconds (`retry_wait`). If the retry limit has not been disabled (`disable_retry_limit` is false) and the retry count exceeds the specified limit (`retry_limit`), the chunk is trashed. The retry wait time doubles each time (1.0sec, 2.0sec, 4.0sec, ...). If the queue length exceeds the specified limit (`buffer_queue_limit`), new events are rejected.

All buffered output plugins support the following parameters:

    :::text
    <match pattern>
      buffer_type memory
      buffer_chunk_limit 256m
      buffer_queue_limit 128
      flush_interval 60s
      disable_retry_limit false
      retry_limit 17
      retry_wait 1s
    </match>

`buffer_type` specifies the buffer plugin to use. The `memory` Buffer plugin is used by default. You can also specify `file` as the buffer type alongside the `buffer_path` parameter as follows:

    :::text
    <match pattern>
      buffer_type file
      buffer_path /var/fluentd/buffer/ #make sure fluentd has write access to the directory!
      ...
    </match>

The suffixes “s” (seconds), “m” (minutes), and “h” (hours) can be used for `flush_interval` and `retry_wait`. `retry_wait` can also be a decimal value.

The suffixes “k” (KB), “m” (MB), and “g” (GB) can be used for `buffer_chunk_limit`.

## Time Sliced Plugin Overview

Time Sliced Plugin is a type of Buffer Plugin, so, it has the same basic buffer structure as Buffer Plugin.

In addition, each chunk is keyed by time and flushed when that chunk's timestamp has passed. This is different from This immediately raises a couple of questions.

1. How do we specify the granularity of time chunks? This is done through the `time_slice_format` option, which is set to "%Y%m%d" (daily) by default. If you want your chunks to be hourly, "%Y%m%d%H" will do the job.
2. What if new logs come after the time corresponding the current chunk? For example, what happens to an event, timestamped at 2013-01-01 02:59:45 UTC, comes in at 2013-01-01 03:00:15 UTC? Would it make into the 2013-01-01 02:00:00-02:59:59 chunk?
  
  This issue is addressed by setting the `time_slice_wait` parameter. `time_slice_wait` sets, in seconds, how long fluentd waits to accept "late" events into the chunk *past the max time corresponding to that chunk*. The default value is 600, which means it waits for 10 minutes before moving on. So, in the current example, as long as the events come in before 2013-01-01 03:10:00, it will make it in to the 2013-01-01 02:00:00-02:59:59 chunk.

  Alternatively, you can also flush the chunks regularly using `flush_interval`. Note that `flush_interval` and `time_slice_wait` are mutually exclusive. If you set `flush_interval`, `time_slice_wait` will be ignored and fluentd would issue a warning.

<img style="display:block;" src="http://image.slidesharecdn.com/fluentdmeetup-diveintofluentplugin-120203210125-phpapp02/95/slide-60-728.jpg"/>

##Notes

If you are curious which core output plugin use Buffered and which are Time Sliced, please see [the list here](http://docs.fluentd.org/articles/output-plugin-overview#overview)

## List of Buffer Plugins

* [buf_memory](buf_memory)
* [buf_file](buf_file)
