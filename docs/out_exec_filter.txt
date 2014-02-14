# exec_filter Output Plugin

The `out_exec_filter` Buffered Output plugin (1) executes an external program using an event as input and (2) reads a new event from the program output. It passes tab-separated values (TSV) to stdin and reads TSV from stdout by default.

## Example Configuration

`out_exec_filter` is included in Fluentd's core. No additional installation process is required.

    :::text
    <match pattern>
      type exec_filter
      command cmd arg arg
      in_keys k1,k2,k3
      out_keys k1,k2,k3,k4
      tag_key k1
      time_key k2
      time_format %Y-%m-%d %H:%M:%S
    </match>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

## Parameters

### type (required)
The value must be `exec_filter`.

### command (required)
The command (program) to execute. The `out_exec_filter` plugin passes the incoming event to the program input and receives the filtered event from the program output.

### in_format
The format used to map the incoming event to the program input.

The following formats are supported:

* tsv (default)

When using the tsv format, please also specify the comma-separated `in_keys` parameter.

    :::text
    in_keys k1,k2,k3

* json
* msgpack

### out_format
The format used to process the program output.

The following formats are supported:

* tsv (default)

When using the tsv format, please also specify the comma-separated `out_keys` parameter.

    :::text
    out_keys k1,k2,k3,k4

* json
* msgpack

NOTE: When using the json format, this plugin uses the Yajl library to parse the program output. Yajl buffers data internally so the output isn't always instantaneous.

### tag_key
The name of the key to use as the event tag. This replaces the value in the event record.

### time_key
The name of the key to use as the event time. This replaces the the value in the event record.

### time_format
The format for event time used when the `time_key` parameter is specified. The default is UNIX time (integer).

INCLUDE: _buffer_parameters

INCLUDE: _log_level_params

