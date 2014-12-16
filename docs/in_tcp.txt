# TCP Input Plugin

The `in_tcp` Input plugin enables Fluentd to accept TCP payload.

### Example Configuration

`in_tcp` is included in Fluentd's core. No additional installation process is required.

    :::text
    <source>
      type tcp
      port 20001 # optional. 5170 by default
      bind 0.0.0.0 # optional. 0.0.0.0 by default
      delimiter \n # optional. \n (newline) by default
    </source>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

### Parameters

#### type (required)
The value must be `tcp`.

#### port
The port to listen to. Default Value = 5170

#### bind
The bind address to listen to. Default Value = 0.0.0.0

#### delimiter
The payload is read up to this character. By default, it is "\n".

#### format
The format of the TCP payload. Required.

INCLUDE: _in_parsers


* regexp

Specify body format by regular expression.

    :::text
    format /^(?<field1>\d+):(?<field2>\w+)$/

If you execute following command:

    :::term
    $ echo '123456:awesome' | netcat 0.0.0.0 5170

then got parsed result like below:

    :::text
    {"field1":"123456","field2":"awesome}

`ltsv`, `tsv`, `csv`, `json` and `none` are also supported.

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

