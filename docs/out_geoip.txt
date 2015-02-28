# GeoIP Output Plugin

The `out_geoip` Buffered Output plugin adds geographic location information to logs using the Maxmind GeoIP databases.

NOTE: This document doesn't describe all parameters. If you want to know full features, check the Further Reading section.

## Prerequisites

* The GeoIP library.

    :::term
    # for RHEL/CentOS
    $ sudo yum install geoip-devel --enablerepo=epel

    # for Ubuntu/Debian
    $ sudo apt-get install libgeoip-dev

    # for MacOSX (brew)
    $ brew install geoip

## Install

`out_geoip` is not included in td-agent. All users must install the fluent-plugin-geoip gem using the following command.

    :::term
    $ fluent-gem install fluent-plugin-geoip
    OR # td-agent 2
    $ sudo /usr/sbin/td-agent-gem install fluent-plugin-geoip
    OR # td-agent 1
    $ sudo /usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-geoip

## Example Configuration

The configuration shown below adds geolocation information to apache.access

    :::text
    <match test.message>
      type geoip
      geoip_lookup_key        host
      enable_key_country_code geoip_country
      enable_key_city         geoip_city
      enable_key_latitude     geoip_lat
      enable_key_longitude    geoip_lon
      remove_tag_prefix       test.
      add_tag_prefix          geoip.
      flush_interval          5s
    </match>


    :::text
    # original record
    test.message {
      "host":"66.102.9.80",
      "message":"test"
    }

    # output record
    geoip.message: {
      "host":"66.102.9.80",
      "message":"test",
      "geoip_country":"US",
      "geoip_city":"Mountain View",
      "geoip_lat":37.4192008972168,
      "geoip_lon":-122.05740356445312
    }

NOTE: Please see the <a href="https://github.com/y-ken/fluent-plugin-geoip#readme">fluent-plugin-geoip README</a> for further details.

## Parameters

### geoip_lookup_key (required)
Specifies the geoip lookup field (default: host)
If accessing a nested hash value, delimit the key with '.', as in 'host.ip'.

### remove_tag_prefix / add_tag_prefix (requires one or the other)
Set tag replace rule.

### enable_key_*** (requires at least one)
Specifies the geographic data that will be added to the record. The supported parameters are shown below:

* enable_key_city
* enable_key_latitude
* enable_key_longitude
* enable_key_country_code3
* enable_key_country_code
* enable_key_country_name
* enable_key_dma_code
* enable_key_area_code
* enable_key_region

### include_tag_key
Set to `true` to include the original tag name in the record. (default: false)

### tag_key
Adds the tag name into the record using this value as the key name When `include_tag_key` is set to `true`.

## Buffer Parameters
For advanced usage, you can tune Fluentd's internal buffering mechanism with these parameters.

### buffer_type
The buffer type is `memory` by default ([buf_memory](buf_memory)). The `file` ([buf_file](buf_file)) buffer type can be chosen as well. Unlike many other output plugins, the `buffer_path` parameter MUST be specified when using `buffer_type file`.

### buffer_queue_limit, buffer_chunk_limit
The length of the chunk queue and the size of each chunk, respectively. Please see the [Buffer Plugin Overview](buffer-plugin-overview) article for the basic buffer structure. The default values are 64 and 256m, respectively. The suffixes “k” (KB), “m” (MB), and “g” (GB) can be used for buffer_chunk_limit.

### flush_interval
The interval between forced data flushes. The default is nil (don't force flush and wait until the end of time slice + time_slice_wait). The suffixes “s” (seconds), “m” (minutes), and “h” (hours) can be used.

INCLUDE: _log_level_params


## Use Cases

#### Plot real time access statistics on a world map using Elasticsearch and Kibana

The `country_code` field is needed to visualize access statistics on a world map using <a href="http://www.elasticsearch.org/overview/kibana/">Kibana</a>.

Note: The following plugins are required:
 * fluent-plugin-geoip
 * fluent-plugin-elasticsearch

    :::text
    <match td.apache.access>
      type geoip

      # Set key name for the client ip address values
      geoip_lookup_key     host

      # Specify key name for the country_code values
      enable_key_country_code  geoip_country

      # Swap tag prefix from 'td.' to 'es.'
      remove_tag_prefix    td.
      add_tag_prefix       es.
    </match>

    <match es.apache.access>
      type            elasticsearch
      host            localhost
      port            9200
      type_name       apache
      logstash_format true
      flush_interval  10s
    </match>

## Further Reading
- [fluent-plugin-geoip repository](https://github.com/y-ken/fluent-plugin-geoip)
