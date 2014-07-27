Storing CloudStack Logs into MongoDB
====================================

[Fluentd](http://fluentd.org) is an open source software to collect events and logs in JSON format. It has hundred of plugins that allows you to store the logs/events in your favorite data store like AWS S3, MongoDB and even elasticsearch. A CloudStack plugin has been written to be able to listen to CloudStack events and store these events in a chosen storage backend. In this chapter we will show how to store CloudStack logs in MongoDB using Fluentd. The [documentation](http://docs.fluentd.org/articles/quickstart) quite straightforward, but here are the basic steps.

You will need a working `fluentd` installed on your machine. Pick your package manager of choice and install `fluentd`, for instance with `gem` we would do:

    :::term
    sudo gem install fluentd

`fluentd` will now be in your path, you need to create a configuration file and start `fluentd` using this config. For additional options with `fluentd` just enter `fluentd -h`. The `s` option will create a sample configuration file in the working directory. The `-c` option will start `fluentd` using the specific configuration file. You can then send a test log/event message to the running process with `fluent-cat`

    :::term	
    $ fluentd -s conf
    $ fluentd -c conf/fluent.conf &
    $ echo '{"json":"message"}' | fluent-cat debug.test

CloudStack Fluentd plugin
========================

CloudStack has a `listEvents` API which does what is says :) it lists events happening within a CloudStack deployment. Such events as the start and stop of a virtual machine, creation of security groups, life cycles events of storage elements, snapshots etc. The `listEvents` API is well [documented](http://cloudstack.apache.org/docs/api/apidocs-4.2/root_admin/listEvents.html). Based mostly on this API and the [fog](http://fog.io) ruby library, a CloudStack plugin for `fluentd` was written by [Yuichi UEMURA](https://github.com/u-ichi). It is slightly different from using `logstash`, as with `logstash` you can format the log4j logs of the CloudStack management server and directly collect those. Here we rely on the `listEvents` API.

Getting Started
---------------

You can install it from source:

    :::term
    git clone https://github.com/u-ichi/fluent-plugin-cloudstack
	
Then build your own gem and install it with `sudo gem build fluent-plugin-cloudstack.gemspec` and `sudo gem install fluent-plugin-cloudstack-0.0.8.gem `
	
Or you install the gem directly:

    :::term
    sudo gem install fluent-plugin-cloudstack
	
Generate a configuration file with `fluentd -s conf`, you can specify the path to your configuration file. Edit the configuration to define a `source` as being from your CloudStack host. For instance if you a running a development environment locally:

    :::text
    <source>
      type cloudstack
      host localhost
      apikey $cloudstack_apikey
      secretkey $cloudstack_secretkey

      # optional
      protocol http             # https or http, default https
      path /client/api          # default /client/api
      port 8080                 # default 443
      #interval 300               # min 300, default 300
      ssl false                 # true or false, default true
      domain_id $cloudstack_domain_id
      tag cloudstack
    </source>
	
There is currently a small bug in the `interval` definition so I commented it out. You also want to define the tag explicitly as being `cloudstack`. You can then create a `<match>` section in the configuration file. To keep it simple at first, we will simply echo the events to `stdout`, therefore just add:
	
    :::text
    <match cloudstack.**>
      type stdout
    </match>

Run `fluentd` with `fluentd -c conf/fluent.conf &`, browse the CloudStack UI, create a VM, create a service offering. Once the interval is passed you will see the events being written to `stdout`:

    :::text
    $ 2013-11-05 12:19:26 +0100 [info]: starting fluentd-0.10.39
    2013-11-05 12:19:26 +0100 [info]: reading config file path="conf/fluent.conf"
    2013-11-05 12:19:26 +0100 [info]: using configuration file: <ROOT>
      <source>
        type forward
      </source>
      <source>
        type cloudstack
        host localhost
        apikey 6QN8jOzEfhR7Fua69vk5ocDo_tfg8qqkT7-2w7nnTNsSRyPXyvRRAy23683qcrflgliHed0zA3m0SO4W9kh2LQ
        secretkey HZiu9vhPAxA8xi8jpGWMWb9q9f5OL1ojW43Fd7zzQIjrcrMLoYekeP1zT9d-1B3DDMMpScHSR9gAnnG45ewwUQ
        protocol http
        path /client/api
        port 8080
        interval 3
        ssl false
        domain_id a9e4b8f0-3fd5-11e3-9df7-78ca8b5a2197
        tag cloudstack
      </source>
      <match debug.**>
        type stdout
      </match>
      <match cloudstack.**>
        type stdout
      </match>
    </ROOT>
    2013-11-05 12:19:26 +0100 [info]: adding source type="forward"
    2013-11-05 12:19:26 +0100 [info]: adding source type="cloudstack"
    2013-11-05 12:19:27 +0100 [info]: adding match pattern="debug.**" type="stdout"
    2013-11-05 12:19:27 +0100 [info]: adding match pattern="cloudstack.**" type="stdout"
    2013-11-05 12:19:27 +0100 [info]: listening fluent socket on 0.0.0.0:24224
    2013-11-05 12:19:27 +0100 [info]: listening cloudstack api on localhost
    2013-11-05 12:19:30 +0100 cloudstack.usages: {"events_flow":0}
    2013-11-05 12:19:30 +0100 cloudstack.usages: {"vm_sum":1,"memory_sum":536870912,"cpu_sum":1,"root_volume_sum":1400,"data_volume_sum":0,"Small Instance":1}
    2013-11-05 12:19:33 +0100 cloudstack.usages: {"events_flow":0}
    2013-11-05 12:19:33 +0100 cloudstack.usages: {"vm_sum":1,"memory_sum":536870912,"cpu_sum":1,"root_volume_sum":1400,"data_volume_sum":0,"Small Instance":1}
    2013-11-05 12:19:36 +0100 cloudstack.usages: {"events_flow":0}
    2013-11-05 12:19:36 +0100 cloudstack.usages: {"vm_sum":1,"memory_sum":536870912,"cpu_sum":1,"root_volume_sum":1400,"data_volume_sum":0,"Small Instance":1}
    2013-11-05 12:19:39 +0100 cloudstack.usages: {"events_flow":0}
    ...
    2013-11-05 12:19:53 +0100 cloudstack.event: {"id":"b5051963-33e5-4f44-83bc-7b78763dcd24","username":"admin","type":"VM.DESTROY","level":"INFO","description":"Successfully completed destroying Vm. Vm Id: 17","account":"admin","domainid":"a9e4b8f0-3fd5-11e3-9df7-78ca8b5a2197","domain":"ROOT","created":"2013-11-05T12:19:53+0100","state":"Completed","parentid":"d0d47009-050e-4d94-97d9-a3ade1c80ee3"}
    2013-11-05 12:19:53 +0100 cloudstack.event: {"id":"39f8ff37-515c-49dd-88d3-eeb77d556223","username":"admin","type":"VM.DESTROY","level":"INFO","description":"destroying Vm. Vm Id: 17","account":"admin","domainid":"a9e4b8f0-3fd5-11e3-9df7-78ca8b5a2197","domain":"ROOT","created":"2013-11-05T12:19:53+0100","state":"Started","parentid":"d0d47009-050e-4d94-97d9-a3ade1c80ee3"}
    2013-11-05 12:19:53 +0100 cloudstack.event: {"id":"d0d47009-050e-4d94-97d9-a3ade1c80ee3","username":"admin","type":"VM.DESTROY","level":"INFO","description":"destroying vm: 17","account":"admin","domainid":"a9e4b8f0-3fd5-11e3-9df7-78ca8b5a2197","domain":"ROOT","created":"2013-11-05T12:19:53+0100","state":"Scheduled"}
    2013-11-05 12:19:55 +0100 cloudstack.usages: {"events_flow":3}
    2013-11-05 12:19:55 +0100 cloudstack.usages: {"vm_sum":1,"memory_sum":536870912,"cpu_sum":1,"root_volume_sum":1400,"data_volume_sum":0,"Small Instance":1}
    ...
    2013-11-05 12:20:18 +0100 cloudstack.event: {"id":"11136a76-1de0-4907-b31d-2557bc093802","username":"admin","type":"SERVICE.OFFERING.CREATE","level":"INFO","description":"Successfully completed creating service offering. Service offering id=13","account":"system","domainid":"a9e4b8f0-3fd5-11e3-9df7-78ca8b5a2197","domain":"ROOT","created":"2013-11-05T12:20:18+0100","state":"Completed"}
    2013-11-05 12:20:19 +0100 cloudstack.usages: {"events_flow":1}
    2013-11-05 12:20:19 +0100 cloudstack.usages: {"vm_sum":1,"memory_sum":536870912,"cpu_sum":1,"root_volume_sum":1400,"data_volume_sum":0,"Small Instance":1}

I cut some of the output for brevity, note that I do have an interval listed as `3` because I did not want to wait 300 minutes. Therefore I installed from source and patched the plugin, it should be fixed in the source soon. You might have a different endpoint and of course different keys, and don't worry about me sharing that `secret_key` I am using a simulator, that key is already gone.
	
Plugging MongoDB
----------------

Getting the events and usage information on stdout is interesting, but the kicker comes from storing the data in a database or a search index. In this section we show to get closer to reality and use [MongoDB](http://www.mongodb.org) to store the data. MongoDB is an open source document database which is schemaless and stores document in JSON format (BSON actually). Installation and query syntax of MongoDB is beyond the scope of this chapter. MongoDB clusters can be setup with replication and sharding, in this section we use MongoDB on a single host with no sharding or replication. To use MongoDB as a storage backend for the events, we first need to install `mongodb`. On single OSX node this is as simple as `sudo port install mongodb`. For other OS use the appropriate package manager. You can then start mongodb with `sudo mongod --dbpath=/path/to/your/databases`. Create a `fluentd` database and a `fluentd` user with read/write access to it. In the mongo shell do:

    :::term
    $sudo mongo
    >use fluentd
	>db.AddUser({user:"fluentd", pwd: "foobar", roles: ["readWrite", "dbAdmin"]})

We then need to install the `fluent-plugin-mongodb`. Still using `gem` this will be done like so:

    :::text
    $sudo gem install fluent-plugin-mongo.

The complete [documentation](http://docs.fluentd.org/articles/out_mongo) also explains how to modify the configuration of `fluentd` to use this backend. Previously we used `stdout` as the output backend, to use `mongodb` we just need to write a different `<match>` section like so:
	
    :::text
    # Single MongoDB
    <match cloudstack.**>
      type mongo
      host fluentd
      port 27017
      database fluentd
      collection test

      # for capped collection
      capped
      capped_size 1024m

      # authentication
      user fluentd
      password foobar

      # flush
      flush_interval 10s
    </match>

Note that you cannot have multiple `match` section for the same tag pattern.

To view the events/usages in Mongo, simply start a mongo shell with `mongo -u fluentd -p foobar fluentd` and list the collections. You will see the `test` collection:

    :::term
    $ mongo -u fluentd -p foobar fluentd
    MongoDB shell version: 2.4.7
    connecting to: fluentd
    Server has startup warnings: 
    Fri Nov  1 13:11:44.855 [initandlisten] 
    Fri Nov  1 13:11:44.855 [initandlisten] ** WARNING: soft rlimits too low. Number of files is 256, should be at least 1000
    > show collections
    system.indexes
    system.users
    test

Couple MongoDB commands will get your rolling, `db.getCollection`, `count()` and `findOne()`:

    :::term
    > coll=db.getCollection('test')
    fluentd.test
    > coll.count()
    181
    > coll.findOne()
    {
    	"_id" : ObjectId("5278d9822675c98317000001"),
	    "events_flow" : 0,
	    "time" : ISODate("2013-11-05T11:41:47Z")
    }
     
The `find()` call returns all entries in the collection. 

    :::term
    > coll.find()
    { "_id" : ObjectId("5278d9822675c98317000001"), "events_flow" : 0, "time" : ISODate("2013-11-05T11:41:47Z") }
    { "_id" : ObjectId("5278d9822675c98317000002"), "vm_sum" : 0, "memory_sum" : 0, "cpu_sum" : 0, "root_volume_sum" : 1500, "data_volume_sum" : 0, "Small Instance" : 1, "time" : ISODate("2013-11-05T11:41:47Z") }
    { "_id" : ObjectId("5278d98d2675c98317000009"), "events_flow" : 0, "time" : ISODate("2013-11-05T11:41:59Z") }
    { "_id" : ObjectId("5278d98d2675c9831700000a"), "vm_sum" : 0, "memory_sum" : 0, "cpu_sum" : 0, "root_volume_sum" : 1500, "data_volume_sum" : 0, "Small Instance" : 1, "time" : ISODate("2013-11-05T11:41:59Z") }
    { "_id" : ObjectId("5278d98d2675c9831700000b"), "id" : "1452c56a-a1e4-43d2-8916-f83a77155a2f", "username" : "admin", "type" : "VM.CREATE", "level" : "INFO", "description" : "Successfully completed starting Vm. Vm Id: 19", "account" : "admin", "domainid" : "a9e4b8f0-3fd5-11e3-9df7-78ca8b5a2197", "domain" : "ROOT", "created" : "2013-11-05T12:42:01+0100", "state" : "Completed", "parentid" : "df68486e-c6a8-4007-9996-d5c9a4522649", "time" : ISODate("2013-11-05T11:42:01Z") }
    { "_id" : ObjectId("5278d98d2675c9831700000c"), "id" : "901f9408-ae05-424f-92cd-5693733de7d6", "username" : "admin", "type" : "VM.CREATE", "level" : "INFO", "description" : "starting Vm. Vm Id: 19", "account" : "admin", "domainid" : "a9e4b8f0-3fd5-11e3-9df7-78ca8b5a2197", "domain" : "ROOT", "created" : "2013-11-05T12:42:00+0100", "state" : "Scheduled", "parentid" : "df68486e-c6a8-4007-9996-d5c9a4522649", "time" : ISODate("2013-11-05T11:42:00Z") }
    { "_id" : ObjectId("5278d98d2675c9831700000d"), "id" : "df68486e-c6a8-4007-9996-d5c9a4522649", "username" : "admin", "type" : "VM.CREATE", "level" : "INFO", "description" : "Successfully created entity for deploying Vm. Vm Id: 19", "account" : "admin", "domainid" : "a9e4b8f0-3fd5-11e3-9df7-78ca8b5a2197", "domain" : "ROOT", "created" : "2013-11-05T12:42:00+0100", "state" : "Created", "time" : ISODate("2013-11-05T11:42:00Z") }
    { "_id" : ObjectId("5278d98d2675c9831700000e"), "id" : "924ba8b9-a9f2-4274-8bbd-c27947d2c246", "username" : "admin", "type" : "VM.CREATE", "level" : "INFO", "description" : "starting Vm. Vm Id: 19", "account" : "admin", "domainid" : "a9e4b8f0-3fd5-11e3-9df7-78ca8b5a2197", "domain" : "ROOT", "created" : "2013-11-05T12:42:00+0100", "state" : "Started", "parentid" : "df68486e-c6a8-4007-9996-d5c9a4522649", "time" : ISODate("2013-11-05T11:42:00Z") }
    { "_id" : ObjectId("5278d98d2675c9831700000f"), "events_flow" : 4, "time" : ISODate("2013-11-05T11:42:02Z") } 
    { "_id" : ObjectId("5278d98d2675c98317000010"), "vm_sum" : 1, "memory_sum" : 536870912, "cpu_sum" : 1, "root_volume_sum" : 1600, "data_volume_sum" : 0, "Small Instance" : 1, "time" : ISODate("2013-11-05T11:42:02Z") }
    Type "it" for more

We leave it to you to learn the MongoDB query syntax and the great aggregation framework, have fun.
