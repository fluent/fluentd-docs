# exec Input Plugin

The `in_exec` Input plugin executes external programs to receive or pull event logs. It will then read TSV (tab separated values), JSON or MessagePack from the stdout of the program.

You can run a program periodically or permanently. To run periodically, please use the run_interval parameter.

## Example Configuration

`in_exec` is included in Fluentd's core. No additional installation process is required.

    :::text
    <source>
      type exec
      command cmd arg arg
      keys k1,k2,k3
      tag_key k1
      time_key k2
      time_format %Y-%m-%d %H:%M:%S
      run_interval 10s
    </source>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

## Parameters

#### type (required)
The value must be `exec`.

#### command (required)
The command (program) to execute.

#### format
The format used to map the program output to the incoming event.

The following formats are supported:

* tsv (default)
* json
* msgpack

When using the tsv format, please also specify the comma-separated `keys` parameter.

    :::text
    keys k1,k2,k3
    
#### tag (required if tag_key is not specified)
tag of the output events.

#### tag_key
The key to use as the event tag instead of the value in the event record. If this parameter is not specified, the `tag` parameter will be used instead.

#### time_key
The key to use as the event time instead of the value in the event record. If this parameter is not specified, the current time will be used instead.

#### time_format
The format of the event time used for the time_key parameter. The default is UNIX time (integer).

#### run_interval
The interval time between periodic program runs.

INCLUDE: _log_level_params

## Real World Use Case: using in_exec to scrape Hacker News Top Page

If you already have a script that runs periodically (say, via `cron`) that you wish to store the output to multiple backend systems (HDFS, AWS, Elasticsearch, etc.), in_exec is a great choice.

The only requirement for the script is that it outputs TSV, JSON or MessagePack.

For example, the [following script](https://gist.github.com/kiyoto/1bd903ad1bdd6ac51fcc) scrapes the front page of [Hacker News](http://news.ycombinator.com) and scrapes information about each post:

<iframe style="width:640px;height:400px" src="https://gist.github.com/kiyoto/1bd903ad1bdd6ac51fcc.pibb?scroll=true"></iframe>

Suppose that script is called `hn.rb`. Then, you can run it every 5 minutes with the following configuration

    :::text
    <source>
      type exec
      format json
      tag hackernews
      command ruby /path/to/hn.rb
      run_interval 5m # don't hit HN too frequently!
    </source>
    <match hackernews>
      type stdout
    </match>

And if you run Fluentd with it, you will see the following output (if you are impatient, ctrl-C to flush the stdout buffer)

    :::text
    2014-05-26 21:51:35 +0000 hackernews: {"time":1401141095,"rank":1,"title":"Rap Genius Co-Founder Moghadam Fired","points":128,"user_name":"obilgic","duration":"2 hours ago  ","num_comments":108}
    2014-05-26 21:51:35 +0000 hackernews: {"time":1401141095,"rank":2,"title":"Whitewood Under Siege: Wooden Shipping Pallets","points":128,"user_name":"drjohnson","duration":"3 hours ago  ","num_comments":20}
    2014-05-26 21:51:35 +0000 hackernews: {"time":1401141095,"rank":3,"title":"Organic Cat Litter Chief Suspect In Nuclear Waste Accident","points":55,"user_name":"timr","duration":"2 hours ago  ","num_comments":12}
    2014-05-26 21:51:35 +0000 hackernews: {"time":1401141095,"rank":4,"title":"Do We Really Know What Makes Us Healthy? (2007)","points":27,"user_name":"gwern","duration":"1 hour ago  ","num_comments":9}

Of course, you can use Fluentd's many output plugins to store the data into various backend systems like [Elasticsearch](free-alternative-to-splunk-by-fluentd), [HDFS](http-to-hdfs), [MongoDB](apache-to-mongodb), [AWS](apache-to-s3), etc.