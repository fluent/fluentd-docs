# HDFS (WebHDFS) Output Plugin

The `out_webhdfs` TimeSliced Output plugin writes records into HDFS (Hadoop Distributed File System). By default, it creates files on an hourly basis. This means that when you first import records using the plugin, no file is created immediately. The file will be created when the `time_slice_format` condition has been met. To change the output frequency, please modify the `time_slice_format` value.

NOTE: This document doesn't describe all parameters. If you want to know full features, check the Further Reading section.

## Install

`out_webhdfs` is included in td-agent by default (v1.1.10 or later). Fluentd gem users will have to install the fluent-plugin-webhdfs gem using the following command.

    :::term
    $ fluent-gem install fluent-plugin-webhdfs

## HDFS Configuration

Append operations are not enabled by default on CDH. Please put these configurations into your hdfs-site.xml file and restart the whole cluster.

    <property>
      <name>dfs.webhdfs.enabled</name>
      <value>true</value>
    </property>
    
    <property>
      <name>dfs.support.append</name>
      <value>true</value>
    </property>
    
    <property>
      <name>dfs.support.broken.append</name>
      <value>true</value>
    </property>

## Example Configuration

    :::text
    <match access.**>
      type webhdfs
      host namenode.your.cluster.local
      port 50070
      path /path/on/hdfs/access.log.%Y%m%d_%H.${hostname}.log
      flush_interval 10s
    </match>

Please see the [Fluentd + HDFS: Instant Big Data Collection](http-to-hdfs) article for real-world use cases.

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

## Parameters

### type (required)
The value must be `webhfds`.

### host (required)
The namenode hostname.

### port (required)
The namenode port number.

### path (required)
The path on HDFS. Please include ${hostname} in your path to avoid writing into the same HDFS file from multiple Fluentd instances. This conflict could result in data loss.

INCLUDE: _timesliced_buffer_parameters

INCLUDE: _log_level_params


## Further Reading
- [fluent-plugin-webhdfs repository](https://github.com/fluent/fluent-plugin-webhdfs)
- [Slides: Fluentd and WebHDFS](http://www.slideshare.net/tagomoris/fluentd-and-webhdfs)
