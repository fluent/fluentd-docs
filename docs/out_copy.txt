# copy Output Plugin

The `copy` output plugin copies events to multiple outputs.

## Example Configuration

`out_copy` is included in Fluentd's core. No additional installation process is required.

    :::text
    <match pattern>
      type copy
      <store>
        type file
        path /var/log/fluent/myapp1
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

Here is an example set up to send events to both a local file under `/var/log/fluent/myapp` and the collection `fluentd.test` in a local MongoDB instance (Please see the [out_file](/articles/out_file) and [out_mongo](/articles/out_mongo) articles for more details about the respective plugins.)

    :::text
    <match myevent.file_and_mongo>
      type copy
      <store>
        type file
        path /var/log/fluent/myapp
        time_slice_format %Y%m%d
        time_slice_wait 10m
        time_format %Y%m%dT%H%M%S%z
        compress gzip
        utc
      </store>
      <store>
        type mongo
        host fluentd
        port 27017
        database fluentd
        collection test
      </store>
    </match>

## Parameters

### type (required)
The value must be `copy`.

### deep_copy
`out_copy` shares a record between `store` plugins by default.

When `deep_copy` is true, `out_copy` passes different record to each `store` plugin.

### &lt;store&gt; (at least one required)
Specifies the storage destinations. The format is the same as the &lt;match&gt; directive.

INCLUDE: _log_level_params

