# Cloud Big Data Analytics with Treasure Data

This article explains how to use [Fluentd](http://fluentd.org/)'s [Treasure Data Output plugin](http://github.com/treasure-data/fluent-plugin-td/) to aggregate semi-structured logs into Treasure Data (TD), which offers Cloud Data Service.

## Background

[Fluentd](http://fluentd.org/) is an advanced open-source log collector originally developed at [Treasure Data, Inc](http://www.treasuredata.com/). Fluentd is specifically designed to solve the big-data log collection problem.

[Treasure Data](http://www.fluentd.org/treasuredata) provides Cloud Data Service, which Fluentd users can use to easily store and analyze data on the cloud. Fluentd is designed to flexibly connect with many systems via plugins, but Treasure Data should be your top choice if you don't want to spend engineering resources maintaining your backend infrastructure.

This article will show you how to use [Fluentd](http://fluentd.org/) to receive data from HTTP and stream it into TD.

## Architecture

The figure below shows the high-level architecture.

<center>
<img width="600" src="/images/treasuredata_architecture.png" />
</center><br /><br />

## Install

For simplicity, this article will describe how to set up an one-node configuration. Please install the following software on the same node.

* [Fluentd](http://fluentd.org/) 
* [TD Output Plugin](https://github.com/treasure-data/fluent-plugin-td)

The TD Output plugin is included in Fluentd’s deb/rpm package (`td-agent`) by default. If you want to use Ruby Gems to install the plugin, please use `gem install fluent-plugin-td`.

* [Debian Package](install-by-deb)
* [RPM Package](install-by-rpm)
* [Ruby gem](install-by-gem)

## Signup

Next, please [sign up](https://console.treasure-data.com/users/sign_up) to TD and get your apikey using the `td apikey:show` command.

    :::term
    $ td account -f
    Enter your Treasure Data credentials.
    Email: your.email@gmail.com
    Password (typing will be hidden):
    $ td apikey:show
    kdfasklj218dsakfdas0983120

## Fluentd Configuration

Let’s start configuring Fluentd. If you used the deb/rpm package, Fluentd's config file is located at /etc/td-agent/td-agent.conf. Otherwise, it is located at /etc/fluentd/fluentd.conf.

### HTTP Input

For the input source, we will set up Fluentd to accept records from HTTP. The Fluentd configuration file should look like this:

    <source>
      type http
      port 8888
    </source>

### Treasure Data Output

The output destination will be Treasure Data. The output configuration should look like this:

    # Treasure Data output
    <match td.*.*>
      type tdlog
      apikey YOUR_API_KEY_IS_HERE
      auto_create_table
      buffer_type file
      buffer_path /var/log/td-agent/buffer/td
      use_ssl true
    </match>

The match section specifies the regexp used to look for matching tags. If a matching tag is found in a log, then the config inside `<match>...</match>` is used (i.e. the log is routed according to the config inside).

## Test

To test the configuration, just post the JSON to Fluentd. Sending a USR1 signal flushes Fluentd's buffer into TD.

    :::term
    $ curl -X POST -d 'json={"action":"login","user":2}' \
      http://localhost:8888/td.testdb.www_access
    $ kill -USR1 `cat /var/run/td-agent/td-agent.pid`

Next, please use the `td tables` command. If the count is not zero, the data was imported successfully.

    :::term
    $ td tables
    +----------+------------+------+-------+--------+
    | Database | Table      | Type | Count | Schema |
    +----------+------------+------+-------+--------+
    | testdb   | www_access | log  |     1 |        |
    +----------+------------+------+-------+--------+

You can now issues queries against the imported data.

    :::term
    $ td query -w -d testdb \
      "SELECT COUNT(1) AS cnt FROM www_access"
    queued...
    started at 2012-04-10T23:44:41Z
    2012-04-10 23:43:12,692 Stage-1 map = 0%,  reduce = 0%
    2012-04-10 23:43:18,766 Stage-1 map = 100%,  reduce = 0%
    2012-04-10 23:43:32,973 Stage-1 map = 100%,  reduce = 100%
    Status     : success
    Result     :
    +-----+
    | cnt |
    +-----+
    |   1 |
    +-----+

NOTE: It's not advisable to send sensitive user information to the cloud. To assist with this need, out_tdlog comes with some anonymization systems. Please see the <a href="http://github.com/treasure-data/fluent-plugin-td/">Treasure Data plugin</a> article for details.

## Conclusion

Fluentd + Treasure Data gives you a data collection and analysis system in days, not months. Treasure Data is a useful solution if you don't want to spend engineering resources maintaining the backend storage and analytics infrastructure.

## Learn More

* [Fluentd Architecture](architecture)
* [Fluentd Get Started](quickstart)
* [Treasure Data](http://www.fluentd.org/treasuredata)
* [Treasure Data: Documentation](http://docs.treasuredata.com/)
