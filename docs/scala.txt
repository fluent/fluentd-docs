# Data Import from Scala Applications

The '[fluent-logger-scala](http://github.com/oza/fluent-logger-scala)' library is used to post records from Scala applications to Fluentd.

This article explains how to use the fluent-logger-scala library.

## Prerequisites

  * Basic knowledge of Scala and sbt
  * Basic knowledge of Fluentd
  * Scala 2.9.0 or 2.9.1
  * sbt 0.12.0 or later

## Installing Fluentd

Please refer to the following documents to install fluentd.

* [Install Fluentd with rpm Package](install-by-rpm)
* [Install Fluentd with deb Package](install-by-deb)
* [Install Fluentd with Ruby Gem](install-by-gem)
* [Install Fluentd from source](install-from-source)

## Modifying the Config File

Next, please configure Fluentd to use the [forward Input plugin](in_forward) as its data source.

    :::text
    <source>
      type forward
      port 24224
    </source>
    <match fluentd.test.**>
      type stdout
    </match>

Please restart your agent once these lines are in place.

    :::term
    # for rpm/deb only
    $ sudo /etc/init.d/td-agent restart

## Using fluent-logger-scala

First, please add the following lines to build.sbt. The logger's revision information can be found in the [ChangeLog](https://github.com/oza/fluent-logger-scala/blob/master/ChangeLog).

    resolvers += "Apache Maven Central Repository" at "http://repo.maven.apache.org/maven2/"

    libraryDependencies += "org.fluentd" %% "fluent-logger-scala" % "0.3.0"

or

    resolvers += "Sonatype Repository" at "http://oss.sonatype.org/content/repositories/releases"

    libraryDependencies += "org.fluentd" %% "fluent-logger-scala" % "0.3.0"


Next, please insert the following lines into your application. Further information regarding the API can be found [here](https://github.com/oza/fluent-logger-scala).

    :::Scala
    import org.fluentd.logger.scala.FluentLoggerFactory
    import scala.collection.mutable.HashMap
    
    object Sample {
      val LOG = FluentLoggerFactory.getLogger("fluentd.test")
    
      def main(args: Array[String]): Unit = {
        
        ...
        val data = new HashMap[String, String]();
        data.put("from", "userA");
        data.put("to", "userB");
        LOG.log("follow", data);
        ...
      }
    
    }

Executing the script will send the logs to Fluentd.

    :::term
    $ sbt
    > run

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
