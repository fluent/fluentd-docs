# forward Input Plugin

The `in_forward` Input plugin listens to a TCP socket to receive the event stream. It also listens to an UDP socket to receive heartbeat messages.

This plugin is mainly used to receive event logs from other Fluentd instances, the fluent-cat command, or client libraries. This is by far the most efficient way to retrieve the records.

NOTE: Do <b>NOT</b> use this plugin for inter-DC or public internet data transfer without secure connections. To provide the reliable / low-latency transfer, we assume this plugin is only used within private networks. <br/><br/>If you open up the port of this plugin to the internet, the attacker can easily crash Fluentd by using the specific packet. If you require a secure connection between nodes, please consider using <a href="in_secure_forward">in_secure_forward</a>.

## Example Configuration

`in_forward` is included in Fluentd's core. No additional installation process is required.

    :::text
    <source>
      type forward
      port 24224
      bind 0.0.0.0
    </source>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

## Parameters

#### type (required)
The value must be `forward`.

#### port
The port to listen to. Default Value = 24224

#### bind
The bind address to listen to. Default Value = 0.0.0.0 (all addresses)

#### linger_timeout
The timeout time used to set linger option. The default is 0

#### chunk_size_limit
The size limit of the the received chunk. If the chunk size is larger than this value, then the received chunk is dropped. The default is nil (no limit).

#### chunk_size_warn_limit
The warning size limit of the received chunk. If the chunk size is larger than this value, a warning message will be sent. The default is nil (no warning).

INCLUDE: _log_level_params


### Protocol

This plugin accepts both JSON or [MessagePack](http://msgpack.org/) messages and automatically detects which is used.  Internally, Fluent uses MessagePack as it is more efficient than JSON.

The time value is a platform specific integer and is based on the output of Ruby's `Time.now.to_i` function.  On Linux, BSD and MAC systems, this is the number of seconds since 1970.

Multiple messages may be sent in the same connection.

    :::text
    stream:
      message...

    message:
      [tag, time, record]
      or
      [tag, [[time,record], [time,record], ...]]

    example:
      ["myapp.access", 1308466941, {"a":1}]["myapp.messages", 1308466942, {"b":2}]
      ["myapp.access", [[1308466941, {"a":1}], [1308466942, {"b":2}]]]
