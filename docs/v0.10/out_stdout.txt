# stdout Output Plugin

The `stdout` output plugin prints events to stdout (or logs if launched with daemon mode). This output plugin is useful for debugging purposes.

### Example Configuration

`out_stdout` is included in Fluentd's core. No additional installation process is required.

    :::text
    <match pattern>
      type stdout
    </match>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

### Parameters

#### type (required)
The value must be `stdout`.

#### output_type
Output format. The following formats are supported:

* json
* hash (Ruby's hash)

INCLUDE: _log_level_params

