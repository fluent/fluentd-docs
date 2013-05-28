# Installing Fluentd Using Chef

This article explains how to install Fluentd using Chef.

## Step0: Before Installation

Please follow the [Preinstallation Guide](before-install) to configure your OS properly. This will prevent many unnecessary problems.

## Step1: Import Recipe

The chef recipe to install td-agent can be found [here](https://github.com/treasure-data/chef-td-agent). Please import the recipe, add it to run_list, and upload it to the Chef Server.

## Step2: Run chef-client

Please run chef-client to install td-agent across your machines.

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
