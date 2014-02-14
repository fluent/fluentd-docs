# roundrobin Output Plugin

The `roundrobin` Output plugin distributes events to multiple outputs using a round-robin algorithm.

## Example Configuration

`out_roundrobin` is included in Fluentd's core. No additional installation process is required.

    :::text
    <match pattern>
      type roundrobin
    
      <store>
        type tcp
        host 192.168.1.21
        ...
      </store>
      <store>
        ...
      </store>
      <store>
        ...
      </store>
    </match>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

## Parameters

### type (required)
The value must be `roundrobin`.

### &lt;store&gt; (required at least one)
Specifies the storage destinations. The format is the same as the &lt;match&gt; directive.

INCLUDE: _log_level_params

