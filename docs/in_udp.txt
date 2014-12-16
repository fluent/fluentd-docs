# UDP Input Plugin

The `in_udp` Input plugin enables Fluentd to accept UDP payload.

### Example Configuration

`in_udp` is included in Fluentd's core. No additional installation process is required.

    :::text
    <source>
      type udp
      format /^(?<field1>\d+):(?<field2>\w+)$/ # required
      tag mytag # required
      port 20001 # optional. 5160 by default
      bind 0.0.0.0 # optional. 0.0.0.0 by default
	  body_size_limit 1MB # optional. 4096 bytes by default
    </source>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

### Parameters

#### type (required)
The value must be `udp`.

#### port
The port to listen to. Default Value = 5160

#### bind
The bind address to listen to. Default Value = 0.0.0.0

#### delimiter
The payload is read up to this character. By default, it is "\n".

#### format
The format of the UDP payload. Required.

INCLUDE: _in_parsers


#### source_host_key

The field name of the client's hostname. If set the value, the client's hostname will be set to its key. The default is nil (no adding hostname).

If you set following configuration:

    :::text
    source_host_key client_host

then the client's hostname is set to `client_host` field.

    :::text
    {
        ...
        "foo": "bar",
        "client_host": "client.hostname.org"
    }


INCLUDE: _log_level_params

