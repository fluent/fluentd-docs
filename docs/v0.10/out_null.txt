# null Output Plugin

The `null` output plugin just throws away events.

## Example Configuration

`out_null` is included in Fluentd's core. No additional installation process is required.

    :::text
    <match pattern>
      type null
    </match>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

## Parameters

### type (required)
The value must be `null`.

INCLUDE: _log_level_params

