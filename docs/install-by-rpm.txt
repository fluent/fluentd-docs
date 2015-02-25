# Installing Fluentd Using rpm Package

This article explains how to install the td-agent rpm package, the stable Fluentd distribution package maintained by [Treasure Data, Inc](http://www.treasuredata.com/).

NOTE: Currently, Amazon Linux is NOT supported officially because Amazon Linux doesn't guarantee ABI compatibility. RPM for CentOS 7 may work.

## What is td-agent?

Fluentd is written in Ruby for flexibility, with performance sensitive parts written in C. However, casual users may have difficulty installing and operating a Ruby daemon.

That's why [Treasure Data, Inc](http://www.treasuredata.com/) is providing **the stable distribution of Fluentd**, called `td-agent`. The differences between Fluentd and td-agent can be found <a href="//www.fluentd.org/faqs">here</a>.

NOTE: This installation guide is for td-agent v2, the current stable version. See <a href="td-agent-v1-vs-v2">this page</a> for the comparison between v1 and v2. <a href="install-by-rpm-v1">Here</a> is the rpm installation guide for v1.

## Step 0: Before Installation

Please follow the [Preinstallation Guide](before-install) to configure your OS properly. This will prevent many unnecessary problems.

## Step 1: Install from rpm Repository

CentOS and RHEL 5, 6 and 7 are currently supported.

Executing [install-redhat-td-agent2.sh](http://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh) will automatically install td-agent on your machine. This shell script registers a new rpm repository at `/etc/yum.repos.d/td.repo` and installs the `td-agent` rpm package.

    $ curl -L http://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh

NOTE: It's HIGHLY recommended that you set up <b>ntpd</b> on the node to prevent invalid timestamps in your logs.

## Step2: Launch Daemon

The `/etc/init.d/td-agent` script is provided to start, stop, or restart the agent.

    $ /etc/init.d/td-agent start 
    Starting td-agent: [  OK  ]
    $ /etc/init.d/td-agent status
    td-agent (pid  21678) is running...

The following commands are supported:

    :::term
    $ /etc/init.d/td-agent start
    $ /etc/init.d/td-agent stop
    $ /etc/init.d/td-agent restart
    $ /etc/init.d/td-agent status

Please make sure **your configuration file** is located at `/etc/td-agent/td-agent.conf`.

## Step3: Post Sample Logs via HTTP

By default, `/etc/td-agent/td-agent.conf` is configured to take logs from HTTP and route them to stdout (`/var/log/td-agent/td-agent.log`). You can post sample log records using the curl command.

    :::term
    $ curl -X POST -d 'json={"json":"message"}' http://localhost:8888/debug.test

## Next Steps

You're now ready to collect your real logs using Fluentd. Please see the following tutorials to learn how to collect your data from various data sources.

  * Basic Configuration
    * [Config File](config-file)
  * Application Logs
    * [Ruby](ruby), [Java](java), [Python](python), [PHP](php), [Perl](perl), [Node.js](nodejs), [Scala](scala)
  * Examples
    * [Store Apache Log into Amazon S3](apache-to-s3)
    * [Store Apache Log into MongoDB](apache-to-mongodb)
    * [Data Collection into HDFS](http-to-hdfs)

Please refer to the resources below for further steps.

* [ChangeLog of td-agent](http://docs.treasuredata.com/articles/td-agent-changelog)
* [Chef Cookbook](https://github.com/treasure-data/chef-td-agent/)
