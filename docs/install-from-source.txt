# Installing Fluentd from Source

This article explains how to install Fluentd from source code (git repository). This is useful for developers.

## Step1: Install Ruby interpreter

Please install Ruby >= 1.9.3 and bundler on your local environment.

## Step2: Fetch Source Code

Fetch the source code from github. The official repository is located [here](http://github.com/fluent/fluentd/).

    :::term
    $ git clone https://github.com/fluent/fluentd.git
    $ cd fluentd

## Step3: Build and Install

Build the package with `rake` and install it with `gem`.

    :::term
    $ bundle install
    Fetching gem metadata from https://rubygems.org/.........
    ...
    Your bundle is complete!
    Use `bundle show [gemname]` to see where a bundled gem is installed.
    $ bundle exec rake build
    fluentd xxx built to pkg/fluentd-xxx.gem.
    $ gem install pkg/fluentd-xxx.gem

## Step4: Run

Run the following commands to to confirm that Fluentd was installed successfully:

    :::term
    $ fluentd --setup ./fluent
    $ fluentd -c ./fluent/fluent.conf -vv &
    $ echo '{"json":"message"}' | fluent-cat debug.test

The last command sends Fluentd a message ‘{“json”:”message”}’ with a “debug.test” tag. If the installation was successful, Fluentd will output the following message:

    :::term
    2011-07-10 16:49:50 +0900 debug.test: {"json":"message"}

NOTE: It's HIGHLY recommended that you set up <b>ntpd</b> on the node to prevent invalid timestamps in your logs.

NOTE: For large deployments, you must use <a href="http://www.canonware.com/jemalloc/">jemalloc</a> to avoid memory fragmentation. This is already included in the <a href="install-by-rpm">rpm</a> and <a href="install-by-deb">deb</a> packages.

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
