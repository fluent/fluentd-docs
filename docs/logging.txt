# Logging of Fluentd

This article describes Fluentd's logging mechanism. 

Fluentd has two log layers: global and per plugin. Different log levels can be set for global logging and plugin level logging.

## Log Level

Shown below is the list of supported values, in increasing order of verbosity:

* `fatal`
* `error`
* `warn`
* `info`
* `debug`
* `trace`

The default log level is `info`, and Fluentd outputs `info`, `warn`, `error` and `fatal` logs by default.

## Global Logs

Global logging is used by Fluentd core and plugins that don't set their own log levels.
The global log level can be adjusted up or down.

### Increase Verbosity Level

The `-v` option sets the verbosity to `debug` while the `-vv` option sets the verbosity to `trace`.

    :::term
    $ fluentd -v  ... # debug level
    $ fluentd -vv ... # trace level

These options are useful for debugging purposes.

### Decrease Verbosity Level

The `-q` option sets the verbosity to `warn` while the `-qq` option sets the verbosity to `error`.

    :::term
    $ fluentd -q  ... # warn level
    $ fluentd -qq ... # error level

## Per Plugin Log (Fluentd v0.10.43 and above)

The `log_level` option sets different levels of logging for each plugin. It can be set in each plugin's configuration file. 

For example, in order to debug [in_tail](in_tail) but suppress all but fatal log messages for [in_http](in_http), their respective `log_level` options should be set as follows:

    <source>
        type tail
        log_level debug
        path /var/log/data.log
        ...
    </source>
    <source>
        type http
        log_level fatal
    </source>

If you don't specify the `log_level` parameter, the plugin will use the global log level.

NOTE: Some plugins haven't supported per-plugin logging yet. The <a href="plugin-development#logging">logging section of the Plugin Development article</a> explains how to update such plugins to support the new log level system.

## Suppress repeated stacktrace

Fluentd can suppress same stacktrace with `--suppress-repeated-stacktrace`.
For example, if you pass `--suppress-repeated-stacktrace` to fluentd:

    :::term
    2013-12-04 15:05:53 +0900 [warn]: fluent/engine.rb:154:rescue in emit_stream: emit transaction failed  error_class = RuntimeError error = #<RuntimeError: syslog>
      2013-12-04 15:05:53 +0900 [warn]: fluent/engine.rb:140:emit_stream: /Users/repeatedly/devel/fluent/fluentd/lib/fluent/plugin/out_stdout.rb:43:in `emit'
      [snip]
      2013-12-04 15:05:53 +0900 [warn]: fluent/engine.rb:140:emit_stream: /Users/repeatedly/devel/fluent/fluentd/lib/fluent/plugin/in_object_space.rb:63:in `run'
    2013-12-04 15:05:53 +0900 [error]: plugin/in_object_space.rb:113:rescue in on_timer: object space failed to emit error = "foo.bar" error_class = "RuntimeError" tag = "foo" record = "{ ...}"
    2013-12-04 15:05:55 +0900 [warn]: fluent/engine.rb:154:rescue in emit_stream: emit transaction failed  error_class = RuntimeError error = #<RuntimeError: syslog>
      2013-12-04 15:05:53 +0900 [warn]: fluent/engine.rb:140:emit_stream: /Users/repeatedly/devel/fluent/fluentd/lib/fluent/plugin/o/2.0.0/gems/cool.io-1.1.1/lib/cool.io/loop.rb:96:in `run'
      [snip]

logs are changed to:

    :::term
    2013-12-04 15:05:53 +0900 [warn]: fluent/engine.rb:154:rescue in emit_stream: emit transaction failed  error_class = RuntimeError error = #<RuntimeError: syslog>
      2013-12-04 15:05:53 +0900 [warn]: fluent/engine.rb:140:emit_stream: /Users/repeatedly/devel/fluent/fluentd/lib/fluent/plugin/o/2.0.0/gems/cool.io-1.1.1/lib/cool.io/loop.rb:96:in `run'
      [snip]
      2013-12-04 15:05:53 +0900 [warn]: fluent/engine.rb:140:emit_stream: /Users/repeatedly/devel/fluent/fluentd/lib/fluent/plugin/in_object_space.rb:63:in `run'
    2013-12-04 15:05:53 +0900 [error]: plugin/in_object_space.rb:113:rescue in on_timer: object space failed to emit error = "foo.bar" error_class = "RuntimeError" tag = "foo" record = "{ ...}"
    2013-12-04 15:05:55 +0900 [warn]: fluent/engine.rb:154:rescue in emit_stream: emit transaction failed  error_class = RuntimeError error = #<RuntimeError: syslog>
      2013-12-04 15:05:55 +0900 [warn]: plugin/in_object_space.rb:111:on_timer: suppressed same stacktrace

Same stacktrace is replaced with `suppressed same stacktrace` message until other stacktrace is received.

## Output to log file

Fluentd outputs logs to `STDOUT` by default. To output to a file instead, please specify the `-o` option.

    :::term
    $ fluentd -o /path/to/log_file

NOTE: Fluentd doesn't support log rotation yet.

## Capture Fluentd logs

Fluentd marks its own logs with the `fluent` tag. You can process Fluentd logs by using `<match fluent.**>`. If you define `<match fluent.**>` in your configuration, then Fluentd will send its own logs to this match destination. This is useful for monitoring Fluentd logs.

For example, if you have the following `<match fluent.**>`:

    # omit other source / match
    <match fluent.**>
      type stdout
    </match>

then Fluentd outputs `fluent.info` logs to stdout like below:

    2014-02-27 00:00:00 +0900 [info]: shutting down fluentd
    2014-02-27 00:00:01 +0900 fluent.info: { "message":"shutting down fluentd"} # by <match fluent.**>
    2014-02-27 00:00:01 +0900 [info]: process finished code = 0

In production, you can use [out_forward](out_forward) to send Fluentd logs to a monitoring server.
The monitoring server can then filter and send the logs to your notification system: chat, irc, etc.

Leaf server example:

    # Add hostname for identifing the server and tag to filter by log level
    <match fluent.**>
      type record_modifier
      tag internal.message
      host ${hostname}
      include_tag_key
      tag_key original_tag
    </match>

    <match internal.message>
      type forward
      <server>
        # Monitoring server parameters
      </server>
    </match>

Monitoring server example:

    # Ignore trace, debug and info log
    <match internal.message>
      type grep
      regexp1 original_tag fluent.(warn|error|fatal)
      add_tag_prefix filtered
    </match>

    <match filtered.internal.message>
      # your notification setup. This example uses irc plugin
      type irc
      host irc.domain
      channel notify
      message notice: %s [%s] @%s %s
      out_keys original_tag,time,host,message
    </match>

If an error occurs, you will get a notification message in your irc `notify` channel.

    01:01  fluentd: [11:10:24] notice: fluent.warn [2014/02/27 01:00:00] @leaf.server.domain detached forwarding server 'server.name'

