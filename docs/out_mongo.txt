# MongoDB Output Plugin

The `out_mongo` Buffered Output plugin writes records into [MongoDB](http://mongodb.org/), the emerging document-oriented database system.

NOTE: If you're using ReplicaSet, please see the <a href="out_mongo_replset">out_mongo_replset</a> article instead.

NOTE: This document doesn't describe all parameters. If you want to know full features, check the Further Reading section.

## Why Fluentd with MongoDB?

Fluentd enables your apps to insert records to MongoDB asynchronously with batch-insertion, unlike direct insertion of records from your apps. This has the following advantages:

1. less impact on application performance
2. higher MongoDB insertion throughput while maintaining JSON record structure

## Install

`out_mongo` is included in td-agent by default. Fluentd gem users will need to install the fluent-plugin-mongo gem using the following command.
 
    :::term
    $ fluent-gem install fluent-plugin-mongo

## Example Configuration

    # Single MongoDB
    <match mongo.**>
      type mongo
      host fluentd
      port 27017
      database fluentd
      collection test

      # for capped collection
      capped
      capped_size 1024m

      # authentication
      user michael
      password jordan
      
      # key name of timestamp
      time_key time
      
      # flush
      flush_interval 10s
    </match>

Please see the [Store Apache Logs into MongoDB](apache-to-mongodb) article for real-world use cases.

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

## Parameters

### type (required)
The value must be `mongo`.

### host (required)
The MongoDB hostname.

### port (required)
The MongoDB port.

### database (required)
The database name.

### collection (required, if not tag_mapped)
The collection name.

### capped
This option enables capped collection. This is always recommended because MongoDB is not suited to storing large amounts of historical data.

#### capped_size
Sets the capped collection size.

### user
The username to use for authentication.

### password
The password to use for authentication.

### time_key
The key name of timestamp. (default is "time")

### tag_mapped
This option will allow out_mongo to use Fluentd's tag to determine the destination collection. For example, if you generate records with tags 'mongo.foo', the records will be inserted into the `foo` collection within the `fluentd` database.

    :::text
    <match mongo.*>
      type mongo
      host fluentd
      port 27017
      database fluentd

      # Set 'tag_mapped' if you want to use tag mapped mode.
      tag_mapped

      # If the tag is "mongo.foo", then the prefix "mongo." is removed.
      # The inserted collection name is "foo".
      remove_tag_prefix mongo.

      # This configuration is used if the tag is not found. The default is 'untagged'.
      collection misc
    </match>

This option is useful for flexible log collection.

INCLUDE: _buffer_parameters

INCLUDE: _log_level_params


## Further Reading
- [fluent-plugin-mongo repository](https://github.com/fluent/fluent-plugin-mongo)
