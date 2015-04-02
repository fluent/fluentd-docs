# tail Input Plugin

The `in_tail` Input plugin allows Fluentd to read events from the tail of text files. Its behavior is similar to the `tail -F` command.

### Example Configuration

`in_tail` is included in Fluentd's core. No additional installation process is required.

    :::text
    <source>
      type tail
      path /var/log/httpd-access.log
      pos_file /var/log/td-agent/httpd-access.log.pos
      tag apache.access
      format apache2
    </source>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

### How it Works

* When Fluentd is first configured with `in_tail`, it will start reading from the **tail** of that log, not the beggining.
* Once the log is rotated, Fluentd starts reading the new file from the beggining. It keeps track of the current inode number.
* If `td-agent` restarts, it starts reading from the last position td-agent read before the restart. This position is recorded in the position file specified by the pos_file parameter.

### Parameters

#### type (required)
The value must be `tail`.

#### tag (required)
The tag of the event.

`*` can be used as a placeholder that expands to the actual file path, replacing '/' with '.'. For example, if you have the following configuration

    :::text
    path /path/to/file
    tag foo.*

in_tail emits the parsed events with the 'foo.path.to.file' tag.

#### path (required)
The paths to read. Multiple paths can be specified, separated by ‘,’.

`*` and strftime format can be included to add/remove watch file dynamically. At interval of `refresh_interval`, Fluentd refreshes the list of watch file.

    :::text
    path /path/to/%Y/%m/%d/*

If the date is 20140401, Fluentd starts to watch the files in /path/to/2014/04/01 directory. See also `read_from_head` parameter.

NOTE: You should not use '*' with log rotation because it may cause the log duplication. In such case, you should separate in_tail plugin configuration.

#### exclude_path

The paths to exclude the files from watcher list. For example, if you want to remove compressed files, you can use following pattern.

    :::text
    path /path/to/*
    exclude_path ["/path/to/*.gz", "/path/to/*.zip"]

#### refresh_interval
The interval of refreshing the list of watch file. Default is 60 seconds.

#### read_from_head
Start to read the logs from the head of file, not bottom. The default is `false`.

If you want to tail all contents with `*` or strftime dynamic path, set this parameter to `true`.
Instead, you should guarantee that log rotation will not occur in `*` directory.

#### format (required)
The format of the log. The following templates are supported:

INCLUDE: _in_parsers


INCLUDE: _in_types


### pos_file (highly recommended)
This parameter is highly recommended. Fluentd will record the position it last read into this file.

    :::text
    pos_file /var/log/td-agent/tmp/access.log.pos

#### time_format
The format of the time field. This parameter is required only if the format includes a ‘time’ capture and it cannot be parsed automatically. Please see [Time#strftime](http://www.ruby-doc.org/core-1.9.3/Time.html#method-i-strftime) for additional information.

#### rotate_wait
in_tail actually does a bit more than `tail -F` itself. When rotating a file, some data may still need to be written to the old file as opposed to the new one.

in_tail takes care of this by keeping a reference to the old file (even after it has been rotated) for some time before transitioning completely to the new file. This helps prevent data designated for the old file from getting lost. By default, this time interval is 5 seconds.

The rotate_wait parameter accepts a single integer representing the number of seconds you want this time interval to be.

INCLUDE: _log_level_params

