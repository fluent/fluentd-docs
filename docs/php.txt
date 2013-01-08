# Data Import from PHP Applications

The '[fluent-logger-php](http://github.com/fluent/fluent-logger-php)' library is used to post records from PHP applications to Fluentd.

This article explains how to use the fluent-logger-php library.

## Prerequisites

  * Basic knowledge of PHP
  * Basic knowledge of Fluentd
  * PHP 5.3 or higher

## Installing Fluentd

Please refer to the following documents to install fluentd.

* [Install Fluentd with rpm Package](install-by-rpm)
* [Install Fluentd with deb Package](install-by-deb)
* [Install Fluentd with Ruby Gem](install-by-gem)
* [Install Fluentd from source](install-from-source)

## Modifying the Config File

Next, please configure Fluentd to use the [forward Input plugin](in_forward) as its data source.

    :::text
    # Unix Domain Socket Input
    <source>
      type unix
      path /var/run/td-agent/td-agent.sock
    </source>
    <match fluentd.test.**>
      type stdout
    </match>

Please restart your agent once these lines are in place.

    :::term
    # for rpm/deb only
    $ sudo /etc/init.d/td-agent restart

## Using fluent-logger-php

To use fluent-logger-php, copy the library into your project directory.

    :::term
    $ git clone https://github.com/fluent/fluent-logger-php.git
    $ cp -r src/Fluent <path/to/your_project>

Next, initialize and post the records as shown below.

    :::php
    <?php
    require_once __DIR__.'/src/Fluent/Autoloader.php';
    use Fluent\Logger\FluentLogger;
    Fluent\Autoloader::register();
    $logger = new FluentLogger("unix:///var/run/td-agent/td-agent.sock");
    $logger->post("fluentd.test.follow", array("from"=>"userA", "to"=>"userB"));

Executing the script will send the logs to Fluentd.

    :::term
    $ php test.php

The logs should be output to `/var/log/td-agent/td-agent.log` or stdout of the Fluentd process via the [stdout Output plugin](out_stdout).

## Production Deployments

### Output Plugins
Various [output plugins](output-plugin-overview) are available for writing records to other destinations:

* Examples
  * [Store Apache Logs into Amazon S3](apache-to-s3)
  * [Store Apache Logs into MongoDB](apache-to-mongodb)
  * [Data Collection into HDFS](http-to-hdfs)
* List of Plugin References
  * [Output to Another Fluentd](out_forward)
  * [Output to MongoDB](out_mongo) or [MongoDB ReplicaSet](out_mongo_replset)
  * [Output to Hadoop](out_webhdfs)
  * [Output to File](out_file)
  * [etc...](http://fluentd.org/plugin/)

### High-Availablability Configurations of Fluentd
For high-traffic websites (more than 5 application nodes), we recommend using a high availability configuration of td-agent. This will improve data transfer reliability and query performance.

* [High-Availability Configurations of Fluentd](high-availability)

### Monitoring
Monitoring Fluentd itself is also important. The article below describes general monitoring methods for td-agent.

* [Monitoring Fluentd](monitoring)
