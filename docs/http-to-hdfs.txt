# Fluentd + HDFS: Instant Big Data Collection

This article explains how to use [Fluentd](http://fluentd.org/)'s [WebHDFS Output plugin](http://github.com/fluent/fluent-plugin-webhdfs/) to aggregate semi-structured logs into Hadoop HDFS.

## Background

[Fluentd](http://fluentd.org/) is an advanced open-source log collector originally developed at [Treasure Data, Inc](http://www.treasuredata.com/). Fluentd is specifically designed to solve the big-data log collection problem. A lot of users are using Fluentd with MongoDB, and have found that it doesn't scale well for now.

HDFS (Hadoop) is a natural alternative for storing and processing a huge amount of data, but it didn't have an accessible API other than its Java library until recently. From Apache 1.0.0, CDH3u5, or CDH4 onwards, HDFS supports an HTTP interface called WebHDFS.

This article will show you how to use [Fluentd](http://fluentd.org/) to receive data from HTTP and stream it into HDFS.

## Architecture

The figure below shows the high-level architecture.

<center>
<img src="/images/http-to-hdfs.png" />
</center>

## Install

For simplicity, this article will describe how to set up an one-node configuration. Please install the following software on the same node.

* [Fluentd](http://fluentd.org/)
* [WebHDFS Output Plugin](https://github.com/fluent/fluent-plugin-webhdfs/) ([out_webhdfs](out_webhdfs))
* HDFS (Apache 1.0.0, CDH3u5 or CDH4 onwards)

The WebHDFS Output plugin is included in the latest version of Fluentd's deb/rpm package (v1.1.10 or later). If you want to use Ruby Gems to install the plugin, please use `gem install fluent-plugin-webhdfs`.

* [Debian Package](install-by-deb)
* [RPM Package](install-by-rpm)
* For CDH, please refer to the [downloads page](https://ccp.cloudera.com/display/SUPPORT/CDH+Downloads) (CDH3u5 and CDH4 onwards)
* [Ruby gem](install-by-gem)

## Fluentd Configuration

Let’s start configuring Fluentd. If you used the deb/rpm package, Fluentd's config file is located at /etc/td-agent/td-agent.conf. Otherwise, it is located at /etc/fluentd/fluentd.conf.

### HTTP Input

For the input source, we will set up Fluentd to accept records from HTTP. The Fluentd configuration file should look like this:

    <source>
      type http
      port 8888
    </source>

### WebHDFS Output

The output destination will be WebHDFS. The output configuration should look like this:

    <match hdfs.*.*>
      type webhdfs
      host namenode.your.cluster.local
      port 50070
      path /log/%Y%m%d_%H/access.log.${hostname}
      flush_interval 10s
    </match>

The match section specifies the regexp used to look for matching tags. If a matching tag is found in a log, then the config inside `<match>...</match>` is used (i.e. the log is routed according to the config inside).

**flush_interval** specifies how often the data is written to HDFS. An append operation is used to append the incoming data to the file specified by the **path** parameter.

Placeholders for both time and hostname can be used with the **path** parameter. This prevents multiple Fluentd instances from appending data to the same file, which must be avoided for append operations.

Other options specify HDFS’s NameNode host and port.

## HDFS Configuration

Append operations are not enabled by default. Please put these configurations into your hdfs-site.xml file and restart the whole cluster.

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

Please confirm that the HDFS user has write access to the *path* specified as the WebHDFS output.

## Test

To test the configuration, just post the JSON to Fluentd (we use the curl command in this example). Sending a USR1 signal flushes Fluentd's buffer into WebHDFS.

    :::term
    $ curl -X POST -d 'json={"action":"login","user":2}' \
      http://localhost:8888/hdfs.access.test
    $ kill -USR1 `cat /var/run/td-agent/td-agent.pid`

We can then access HDFS to see the stored data.

    :::term
    $ sudo -u hdfs hadoop fs -lsr /log/
    drwxr-xr-x   - 1 supergroup          0 2012-10-22 09:40 /log/20121022_14/access.log.dev

## Conclusion

Fluentd + WebHDFS make real-time log collection simple, robust and scalable! [@tagomoris](http://github.com/tagomoris) has already been using this plugin to collect 20,000 msgs/sec, 1.5 TB/day without any major problems for several months now.

## Learn More

* [Fluentd Architecture](architecture)
* [Fluentd Get Started](quickstart)
* [WebHDFS Output Plugin](out_webhdfs)
* [Slides: Fluentd and WebHDFS](http://www.slideshare.net/tagomoris/fluentd-and-webhdfs)
