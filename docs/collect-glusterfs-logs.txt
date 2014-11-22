#Collecting GlusterFS Logs with Fluentd

This article shows how to use Fluentd to collect GlusterFS logs for analysis (search, analytics, troubleshooting, etc.)

##Background

[GlusterFS](http://gluster.org) is an open source, distributed file system commercially supported by Red Hat, Inc. Each node in GlusterFS generates its own logs, and it's sometimes convenient to have these logs collected in a central location for analysis (e.g., When one GlusterFS node went down, what was happening on other nodes?).

[Fluentd](architecture) is an open source data collector for high-volume data streams. It's a great fit for monitoring GlusterFS clusters because:

1. Fluentd supports GlusterFS logs as a data source.
2. Fluentd supports various output systems (e.g., Elasticsearch, MongoDB, Treasure Data, etc.) that can help GlusterFS users analyze the logs.

The rest of this article explains how to set up Fluentd with GlusterFS. For this example, we chose Elasticsearch as the backend system.

<img src="/images/glusterfs-fluentd.png"/>

##Setting up Fluentd on GlusterFS Nodes

###Step 1: Installing Fluentd

First, we'll install Fluentd using the following command:

    :::term
    $ curl -L http://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh

Next, we'll install the Fluentd plugin for GlusterFS:

    :::term
    $ sudo /usr/sbin/td-agent-gem install fluent-plugin-glusterfs
    Fetching: fluent-plugin-glusterfs-1.0.0.gem (100%)
    Successfully installed fluent-plugin-glusterfs-1.0.0
    1 gem installed
    Installing ri documentation for fluent-plugin-glusterfs-1.0.0...
    Installing RDoc documentation for fluent-plugin-glusterfs-1.0.0...

###Step 2: Making GlusterFS Log Files Readable by Fluentd

By default, only `root` can read the GlusterFS log files. We'll allow others to read the file.

    :::term
    $ ls -alF /var/log/glusterfs/etc-glusterfs-glusterd.vol.log
    -rw------- 1 root root 1385  Feb  3 07:21 2014 /var/log/glusterfs/etc-glusterfs-glusterd.vol.log
    $ sudo chmod +r /var/log/glusterfs/etc-glusterfs-glusterd.vol.log
    $ ls -alF /var/log/glusterfs/etc-glusterfs-glusterd.vol.log
    -rw-r--r-- 1 root root 1385  Feb  3 07:21 2014 /var/log/glusterfs/etc-glusterfs-glusterd.vol.log

Now, modify Fluentd's configuration file. It is located at `/etc/td-agent/td-agent.conf`.

NOTE: `td-agent` is Fluentd's rpm/deb package maintained by [Treasure Data](http://docs.treasuredata.com/articles/td-agent)

This is what the configuration file should look like:

    :::term
    $ sudo cat /etc/td-agent/td-agent.conf
     
    <source>
      type glusterfs_log
      path /var/log/glusterfs/etc-glusterfs-glusterd.vol.log
      pos_file /var/log/td-agent/etc-glusterfs-glusterd.vol.log.pos
      tag glusterfs_log.glusterd
      format /^(?<message>.*)$/
    </source>
     
    <match glusterfs_log.**>
      type forward
      send_timeout 60s
      recover_wait 10s
      heartbeat_interval 1s
      phi_threshold 8
      hard_timeout 60s
     
      <server>
        name logserver
        host 172.31.10.100
        port 24224
        weight 60
      </server>
     
      <secondary>
        type file
        path /var/log/td-agent/forward-failed
      </secondary>
    </match>

NOTE: the <secondary>...</secondary> section is for failover (when the aggregator instance at 172.31.10.100:24224 is unreachable).

Finally, start td-agent. Fluentd will started with the updated setup.

    $ sudo service td-agent start
    Starting td-agent:                                         [  OK  ]

###Step 3: Setting Up the Aggregator Fluentd Server

We'll now set up a separate Fluentd instance to aggregate the logs. Again, the first step is to install Fluentd.

    :::term
    $ curl -L http://toolbelt.treasuredata.com/sh/install-redhat.sh | sh

We'll set up the node to send data to Elasticsearch, where the logs will be indexed and written to local disk for backup.

First, install the Elasticsearch output plugin as follows:

    :::term
    $ sudo /usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-glusterfs

Then, configure Fluentd as follows:

    :::term
    $ sudo cat /etc/td-agent/td-agent.conf
    <source>
      type forward
      port 24224
      bind 0.0.0.0
    </source>
     
    <match glusterfs_log.glusterd>
      type copy

      #local backup
      <store>
        type file
        path /var/log/td-agent/glusterd
      </store>

      #Elasticsearch
      <store>
        type elasticsearch
        host ELASTICSEARCH_URL_HERE
        port 9200
        index_name glusterfs
        type_name fluentd
        logstash_format true
      </store>
    </match>

That's it! You should now be able to search and visualize your GlusterFS logs with [Kibana](http://www.elasticsearch.org/overview/kibana).

## Acknowledgement

This article is inspired by [Daisuke Sasaki's article on Classmethod's website](http://dev.classmethod.jp/cloud/aws/glusterfs-with-fluentd/). Thanks Daisuke!

## Learn More

- [Fluentd Architecture](architecture)
- [Fluentd Get Started](quickstart)
- [GlusterFS Input Plugin](https://github.com/keithseahus/fluent-plugin-glusterfs)
