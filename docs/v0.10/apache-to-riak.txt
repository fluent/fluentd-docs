# Store Apache Logs into Riak

This article explains how to use Fluentd’s Riak Output plugin ([out_riak](https://github.com/kuenishi/fluent-plugin-riak)) to aggregate semi-structured logs in real-time.

<center>
<img src="http://docs.fluentd.org/images/fluentd-riak.png" height="280px"/>
</center>

## Prerequisites

1. An OSX or Linux machine
2. Fluentd is installed ([installation guide](/categories/installation))
3. Riak is installed
4. An Apache web server log

## Installing the Fluentd Riak Output Plugin

The [Riak output plugin](https://github.com/kuenishi/fluent-plugin-riak) is used to output data from a Fluentd node to a Riak node. 

### Rubygems Users

Rubygems users can run the command below to install the plugin:

    :::term
    $ gem install fluent-plugin-riak

### td-agent Users

If you are using td-agent, run following command to install the Riak output plugin.

* td-agent v2: `/usr/sbin/td-agent-gem install fluent-plugin-riak`
* td-agent v1: `/usr/lib/fluent/ruby/bin/fluent-gem install fluent-plugin-riak

## Configuring Fluentd

Create a configuration file called `fluent.conf` and add the following lines:

    <source>
      type tail
      format apache2
      path /var/log/apache2/access_log
      pos_file /var/log/fluentd/apache2.access_log.pos
      tag riak.apache
    </source>

    <match riak.**>
      type riak
      buffer_type memory
      flush_interval 5s
      retry_limit 5
      retry_wait 1s
      nodes localhost:8087 # Assumes Riak is running locally on port 8087
    </match>

The `<source>...</source>` section tells Fluentd to tail an Apache2-formatted log file located at `/var/log/apache2/access_log`. Each line is parsed as an Apache access log event and tagged with the `riak.apache` label.

The `<match riak.**>...</match>` section tells Fluentd to look for events whose tags start with `riak.` and send all matches to a Riak node located at `localhost:8087`. You can send events to multiple nodes by writing `nodes host1 host2 host3` instead.

## Testing

Launch Fluentd with the following command:

    :::term
    $ fluentd -c fluentd.conf

NOTE: Please confirm that you have the file access permissions to (1) read the Apache log file and (2) write to `/var/log/fluentd/apache2.access_log.pos` (sudo-ing might help).

You should now see data coming into your Riak cluster. We can make sure that everything is running smoothly by hitting Riak's HTTP API:

    :::term
    $ curl http://localhost:8098/buckets/fluentlog/keys?keys=true
    {"keys":["2014-01-23-d30b0698-b9de-4290-b8be-a66555497078", ...]}
    $ curl http://localhost:8098/buckets/fluentlog/keys/2014-01-23-d30b0698-b9de-4290-b8be-a66555497078
    [
      {
        "tag": "riak.apache",
        "time": "2004-03-08T01:23:54Z",
        "host": "64.242.88.10",
        "user": null,
        "method": "GET",
        "path": "/twiki/bin/statistics/Main",
        "code": 200,
        "size": 808,
        "referer": null,
        "agent": null
      }
    ]

There it is! (the response JSON is formatted for readability)

## Learn More

- [Fluentd Architecture](architecture)
- [Fluentd Get Started](quickstart)
- [Riak Output Plugin](http://github.com/kuenishi/fluent-plugin-riak)
