# Unix Domain Socket Input Plugin

The `in_unix` Input plugin enables Fluentd to retrieve records from the Unix Domain Socket. The wire protocol is the same as [in_forward](in_forward), but the transport layer is different.

### Example Configuration

`in_unix` is included in Fluentd's core. No additional installation process is required.

    :::text
    <source>
      type unix
      path /path/to/socket.sock
    </source>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

### Parameters

#### type (required)
The value must be `unix`.

#### path (required)
The path to your Unix Domain Socket.

#### backlog
The backlog of Unix Domain Socket. The default is `1024`.


INCLUDE: _log_level_params

