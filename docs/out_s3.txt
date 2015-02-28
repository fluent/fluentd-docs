# Amazon S3 Output Plugin

The `out_s3` TimeSliced Output plugin writes records into the Amazon S3 cloud object storage service. By default, it creates files on an hourly basis. This means that when you first import records using the plugin, no file is created immediately. The file will be created when the `time_slice_format` condition has been met. To change the output frequency, please modify the `time_slice_format` value.

NOTE: This document doesn't describe all parameters. If you want to know full features, check the Further Reading section.

## Installation

`out_s3` is included in td-agent by default. Fluentd gem users will need to install the fluent-plugin-s3 gem using the following command.

    :::term
    $ fluent-gem install fluent-plugin-s3

## Example Configuration

    :::text
    <match pattern>
      type s3

      aws_key_id YOUR_AWS_KEY_ID
      aws_sec_key YOUR_AWS_SECRET/KEY
      s3_bucket YOUR_S3_BUCKET_NAME
      s3_region ap-northeast-1
      path logs/
      buffer_path /var/log/fluent/s3

      time_slice_format %Y%m%d%H
      time_slice_wait 10m
      utc

      buffer_chunk_limit 256m
    </match>

Please see the [Store Apache Logs into Amazon S3](apache-to-s3) article for real-world use cases.

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

NOTE: Please make sure that you have <b>enough space in the buffer_path directory</b>. Running out of disk space is a problem frequently reported by users.

## Parameters

### type (required)
The value must be `s3`.

### aws_key_id (required/optional)
The AWS access key id. This parameter is required when your agent is not running on an EC2 instance with an IAM Instance Profile.

### aws_sec_key (required/optional)
The AWS secret key. This parameter is required when your agent is not running on an EC2 instance with an IAM Instance Profile.

### s3_bucket (required)
The Amazon S3 bucket name.

### buffer_path (required)
The path prefix of the log buffer files.

### s3_region
The Amazon S3 region name. Please select the appropriate region name from the list below and confirm that your bucket has been created in the correct region.

* us-east-1
* us-west-2
* us-west-1
* eu-west-1
* eu-central-1
* ap-southeast-1
* ap-southeast-2
* ap-northeast-1
* sa-east-1

The most recent versions of the endpoints can be found [here](http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region).

### s3_enpoint

This option is deprecated because latest aws-sdk ignores this option. Please use `s3_region` instead.

The Amazon S3 enpoint name. Please select the appropriate endpoint name from the list below and confirm that your bucket has been created in the correct region.

* s3.amazonaws.com
* s3-us-west-1.amazonaws.com
* s3-us-west-2.amazonaws.com
* s3.sa-east-1.amazonaws.com
* s3-eu-west-1.amazonaws.com
* s3-ap-southeast-1.amazonaws.com
* s3-ap-northeast-1.amazonaws.com

The most recent versions of the endpoints can be found [here](http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region).

### format
The format of the S3 object. The default is `out_file`.

INCLUDE: _formatter_parameters

### time_slice_format
The time format used as part of the file name. The following characters are replaced with actual values when the file is created:

* %Y: year including the century (at least 4 digits)
* %m: month of the year (01..12)
* %d: Day of the month (01..31)
* %H: Hour of the day, 24-hour clock (00..23)
* %M: Minute of the hour (00..59)
* %S: Second of the minute (00..60)

The default format is `%Y%m%d%H`, which creates one file per hour.

### time_slice_wait
The amount of time Fluentd will wait for old logs to arrive. This is used to account for delays in logs arriving to your Fluentd node. The default wait time is 10 minutes ('10m'), where Fluentd will wait until 10 minutes past the hour for any logs that occured within the past hour.

For example, when splitting files on an hourly basis, a log recorded at 1:59 but arriving at the Fluentd node between 2:00 and 2:10 will be uploaded together with all the other logs from 1:00 to 1:59 in one transaction, avoiding extra overhead. Larger values can be set as needed.

### time_format
The format of the time written in files. The default format is ISO-8601.

### path
The path prefix of the files on S3. The default is “” (no prefix).

NOTE: The actual path on S3 will be: “{path}{time_slice_format}_{sequential_index}.gz” (see `s3_object_key_format`)

### s3_object_key_format

The actual S3 path. The default value is %{path}%{time_slice}_%{index}.%{file_extension}, which is interpolated to the actual path (ex: Ruby's variable interpolation).

- path: the value of the `path` parameter above
- time_slice: the time string as formatted by `time_slice_format`
- index: the index for the given path. Incremented per buffer flush
- file_extension: as determined by the `store_as` parameter.

For example, if

- `s3_object_key_format` is as default
- `path` is "hello"
- `time_slice_format` is "%Y%m%d"
- `store_as` is "json"

Then, "hello20141111_0.json" would be an example actual S3 path.

NOTE: This parameter is for advanced users. Most users should NOT modify it. Also, always make sure that %{index} appears in the customized `s3_object_key_format` (Otherwise, multiple buffer flushes within the same time slice throws an error).

### utc
Uses UTC for path formatting. The default format is localtime.

### store_as
The compression type. The default is "gzip", but you can also choose "lzo", "json", or "txt".

### proxy_uri
The proxy url. The default is nil.

### use_ssl
Enable/disable SSL for data transfers between Fluentd and S3. The default is "yes".

INCLUDE: _timesliced_buffer_parameters

INCLUDE: _log_level_params


## Further Reading
This page doesn't describe all the possible configurations. If you want to know about other configurations, please check the link below.

- [fluent-plugin-s3 repository](https://github.com/fluent/fluent-plugin-s3)
