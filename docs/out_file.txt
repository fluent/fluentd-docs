# file Output Plugin

The `out_file` TimeSliced Output plugin writes events to files. By default, it creates files on a daily basis (around 00:10). This means that when you first import records using the plugin, no file is created immediately. The file will be created when the `time_slice_format` condition has been met. To change the output frequency, please modify the `time_slice_format` value.

## Example Configuration

`out_file` is included in Fluentd's core. No additional installation process is required.

    :::text
    <match pattern>
      type file
      path /var/log/fluent/myapp
      time_slice_format %Y%m%d
      time_slice_wait 10m
      time_format %Y%m%dT%H%M%S%z
      compress gzip
      utc
    </match>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

## Parameters

### type (required)
The value must be `file`.

### path (required)
The Path of the file. The actual path is path + time + ”.log”. The time portion is determined by the time_slice_format parameter, descried below.

The `path` parameter is used as `buffer_path` in this plugin.

NOTE: Initially, you may see a file which looks like "/path/to/file.20140101.log.b4eea2c8166b147a0". This is an intermediate buffer file ("b4eea2c8166b147a0" identifies the buffer). Once the content of the buffer has been completely <a href="buf_file">flushed</a>, you will see the output file without the trailing identifier.

### append
The flushed chunk is appended to existence file or not. The default is `false`.
By default, out_file flushes each chunk to different path.

    :::text
    # append false
    log.20140608_0.log
    log.20140608_1.log
    log.20140609_0.log
    log.20140609_1.log

This makes parallel file processing easy. But if you want to disable this behaviour,
you can disable it by setting `append true`.

    :::text
    # append true
    log.20140608.log
    log.20140609.log


### format
The format of the file content. The default is `out_file`.

INCLUDE: _formatter_parameters

### time_slice_format
The time format used as part of the file name. The following characters are replaced with actual values when the file is created:

* %Y: year including the century (at least 4 digits)
* %m: month of the year (01..12)
* %d: Day of the month (01..31)
* %H: Hour of the day, 24-hour clock (00..23)
* %M: Minute of the hour (00..59)
* %S: Second of the minute (00..60)

The default format is `%Y%m%d`, which creates one file per day. To create a file every hour, use `%Y%m%d%H`.

### time_slice_wait
The amount of time Fluentd will wait for old logs to arrive. This is used to account for delays in logs arriving to your Fluentd node. The default wait time is 10 minutes ('10m'), where Fluentd will wait until 10 minutes past the hour for any logs that occured within the past hour.

For example, when splitting files on an hourly basis, a log recorded at 1:59 but arriving at the Fluentd node between 2:00 and 2:10 will be uploaded together with all the other logs from 1:00 to 1:59 in one transaction, avoiding extra overhead. Larger values can be set as needed.

### time_format
The format of the time written in files. The default format is ISO-8601.

### utc
Uses UTC for path formatting. The default format is localtime.

### compress
Compresses flushed files using `gzip`. No compression is performed by default.

### symlink_path

Create symlink to temporary buffered file when `buffer_type` is `file`. No symlink is created by default.
This is useful for tailing file content to check logs.

INCLUDE: _timesliced_buffer_parameters

INCLUDE: _log_level_params

