# Getting Data From Json Into Elasticsearch Using Fluentd

Looking to get data out of json into elasticsearch? You can do that with [fluentd](//fluentd.org) in **10 minutes**!

<table>
  <td><img style="display:inline;width:250px" src="/images/plugin_icon/json.png"/></td>
  <td><span style="font-size:50px">&#8594;</span></td>
  <td><img style="display:inline;width:250px" src="/images/plugin_icon/elasticsearch.png"/></td>
</table>

Here is how:

    :::term
    $ gem install fluentd
    $ gem install fluent-plugin-elasticsearch
    $ touch fluentd.conf

`fluentd.conf` should look like this (just copy and paste this into fluentd.conf):

    :::text
    <source>
      type tail
      path /var/log/httpd-access.log #...or where you placed your Apache access log
      pos_file /var/log/td-agent/httpd-access.log.pos # This is where you record file position
      tag foobar.json #fluentd tag!
      format json # one JSON per line
      time_key time_field # optional; default = time
    </source>
    
    <match **>
      type elasticsearch
      logstash_format true
      host <hostname> #(optional; default="localhost")
      port <port> #(optional; default=9200)
      index_name <index name> #(optional; default=fluentd)
      type_name <type name> #(optional; default=fluentd)
    </match>

After that, you can start fluentd and everything should work:

    :::term
    $ fluentd -c fluentd.conf

Of course, this is just a quick example. If you are thinking of running fluentd in production, consider using [td-agent](//docs.treasure-data.com/articles/td-agent), the enterprise version of Fluentd packaged and maintained by [Treasure Data, Inc.](//www.treasure-data.com).
