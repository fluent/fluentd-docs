# Data Import from Node.js Applications

The '[fluent-logger-node](https://github.com/fluent/fluent-logger-node)' library is used to post records from Node.js applications to Fluentd.

This article explains how to use the fluent-logger-node library.

## Prerequisites

  * Basic knowledge of Node.js and NPM
  * Basic knowledge of Fluentd
  * Node.js 0.6 or higher

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

## Using fluent-logger-node

### Obtaining the Most Recent Version

The most recent version of fluent-logger-node can be found [here](http://search.npmjs.org/#/fluent-logger).

### A Sample Application

A sample [Express](http://expressjs.com/) app using fluent-logger-node is shown below.

#### package.json

    :::js
    {
      "name": "node-example",
      "version": "0.0.1",
      "dependencies": {
        "express": "2.5.9",
        "fluent-logger": "0.1.0"
      }
    }

Now use *npm* to install your dependencies locally:

    :::term
    $ npm install
    fluent-logger@0.1.0 ./node_modules/fluent-logger
    express@2.5.9 ./node_modules/express
    |-- qs@0.4.2
    |-- mime@1.2.4
    |-- mkdirp@0.3.0
    |-- connect@1.8.6 (formidable@1.0.9)

#### web.js

This is the simplest web app.

    :::js
    var express = require('express');
    var app = express.createServer(express.logger());

    var logger = require('fluent-logger');
    logger.configure('fluentd.test', {host: 'localhost', port: 24224});

    app.get('/', function(request, response) {
      logger.emit('follow', {from: 'userA', to: 'userB'});
      response.send('Hello World!');
    });
    var port = process.env.PORT || 3000;
    app.listen(port, function() {
      console.log("Listening on " + port);
    });

Execute the app and go to `http://localhost:3000/` in your browser. This will send the logs to Fluentd.

    :::term
    $ node web.js

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
