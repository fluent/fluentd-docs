# MongoDB ReplicaSet Output Plugin

The `out_mongo_replset` Buffered Output plugin writes records into [MongoDB](http://mongodb.org/), the emerging document-oriented database system. 

NOTE: This plugin is for users using ReplicaSet. If you are not using ReplicaSet, please see the <a href="out_mongo">out_mongo</a> article instead.

## Why Fluentd with MongoDB?

Fluentd enables your apps to insert records to MongoDB asynchronously with batch-insertion, unlike direct insertion of records from your apps. This has the following advantages:

1. less impact on application performance
2. higher MongoDB insertion throughput while maintaining JSON record structure

## Install

`out_mongo_replset` is included in td-agent by default. Fluentd gem users will need to install the fluent-plugin-mongo gem using the following command.

    :::term
    $ fluent-gem install fluent-plugin-mongo

## Example Configuration

    # Single MongoDB
    <match mongo.**>
      type mongo_replset
      database fluentd
      collection test
      nodes localhost:27017,localhost:27018,localhost:27019

      # flush
      flush_interval 10s
    </match>

Please see the [Store Apache Logs into MongoDB](apache-to-mongodb) article for real-world use cases.

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

## Parameters

### type (required)
The value must be `mongo`.

### nodes (required)
The comma separated node strings (e.g. host1:27017,host2:27017,host3:27017).

### database (required)
The database name.

### collection (required if not tag_mapped)
The collection name.

### capped
This option enables capped collection. This is always recommended because MongoDB is not suited to storing large amounts of historical data.

### capped_size
Sets the capped collection size.

### user
The username to use for authentication.

### password
The password to use for authentication.

### tag_mapped
This option will allow out_mongo to use Fluentd's tag to determine the destination collection.

For example, if you generate records with tags 'mongo.foo', the records will be inserted into the `foo` collection within the `fluentd` database.

    :::text
    <match mongo.*>
      type mongo_replset
      database fluentd
      nodes localhost:27017,localhost:27018,localhost:27019

      # Set 'tag_mapped' if you want to use tag mapped mode.
      tag_mapped

      # If the tag is "mongo.foo", then the prefix "mongo." is removed.
      # The inserted collection name is "foo".
      remove_tag_prefix mongo.

      # This configuration is used if the tag is not found. The default is 'untagged'.
      collection misc
    </match>

### name
The ReplicaSet name.

### read
The ReplicaSet read preference (e.g. secondary, etc).

### refresh_mode
The ReplicaSet refresh mode (e.g. sync, etc).

### refresh_interval
The ReplicaSet refresh interval.

### num_retries
The ReplicaSet failover threshold. The default threshold is 60. If the retry count reaches this threshold, the plugin raises an exception.

INCLUDE: _buffer_parameters

INCLUDE: _log_level_params


## Further Readings
- [fluent-plugin-webhdfs mongo](https://github.com/fluent/fluent-plugin-mongo)
