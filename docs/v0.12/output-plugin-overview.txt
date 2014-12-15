# Output Plugin Overview

Fluentd has 6 types of plugins: [Input](input-plugin-overview), [Parser](parser-plugin-overview), [Filter](filter-plugin-overview), [Output](output-plugin-overview), [Formatter](formatter-plugin-overview) and [Buffer](buffer-plugin-overview). This article gives an overview of Filter Plugin.

## Overview

There are three types of output plugins: Non-Buffered, Buffered, and Time Sliced.

* *Non-Buffered* output plugins do not buffer data and immediately write out results.
* *Buffered* output plugins maintain a queue of chunks (a chunk is a collection of events), and its behavior can be tuned by the "chunk limit" and "queue limit" parameters (See the diagram  below).
* *Time Sliced* output plugins are in fact a type of Bufferred plugin, but the chunks are keyed by time (See the diagram below).

<img style="display:block;" src="http://image.slidesharecdn.com/fluentdmeetup-diveintofluentplugin-120203210125-phpapp02/95/slide-60-728.jpg"/>

The output plugin's buffer behavior (if any) is defined by a separate [Buffer plugin](buffer-plugin-overview). Different buffer plugins can be chosen for each output plugin. Some output plugins are fully customized and do not use buffers.

### secondary output

At Buffered output plugin, the user can specify `<secondary>` with any output plugin in `<match>` configuration.
If the retry count exceeds the buffer's `retry_limit` (and the retry limit has
not been disabled via `disable_retry_limit`), then buffered chunk is output to `<secondary>` output plugin.

`<secondary>` is useful for backup when destination servers are unavailable, e.g. forward, mongo and other plugins. We strongly recommend `out_file` plugin for `<secondary>`.

## List of Non-Buffered Output Plugins

* [out_copy](out_copy)
* [out_null](out_null)
* [out_roundrobin](out_roundrobin)
* [out_stdout](out_stdout)

## List of Buffered Output Plugins

* [out_exec_filter](out_exec_filter)
* [out_forward](out_forward)
* [out_mongo](out_mongo) or [out_mongo_replset](out_mongo_replset)

## List of Time Sliced Output Plugins

* [out_exec](out_exec)
* [out_file](out_file)
* [out_s3](out_s3)
* [out_webhdfs](out_webhdfs)

## Other Plugins

Please refer to this list of available plugins to find out about other Output plugins.

* [others](http://fluentd.org/plugin/)
