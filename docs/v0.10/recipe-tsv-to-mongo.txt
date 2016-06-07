# Getting Data From Tsv Into Mongo Using Fluentd

Looking to get data out of tsv into mongo? You can do that with [fluentd](//fluentd.org) in **10 minutes**!

<table>
  <td><img style="display:inline;width:250px" src="/images/plugin_icon/tsv.png"/></td>
  <td><span style="font-size:50px">&#8594;</span></td>
  <td><img style="display:inline;width:250px" src="/images/plugin_icon/mongo.png"/></td>
</table>

Here is how:

    :::term
    $ gem install fluentd
    $ gem install fluent-plugin-mongo
    $ touch fluentd.conf

`fluentd.conf` should look like this (just copy and paste this into fluentd.conf):

    :::text
    <source>
      type tail
      path /var/log/httpd-access.log #...or where you placed your Apache access log
      pos_file /var/log/td-agent/httpd-access.log.pos # This is where you record file position
      tag foobar.tsv #fluentd tag!
      format tsv
      keys key1, key2, key3 # e.g., user_id, timestamp, action
      time_key key2 # Specify the column that you want to use as timestamp
    </source>
    
    <match **>
      type mongo
      database <db name> #(required)
      collection <collection name> #(optional; default="untagged")
      host <hostname> #(optional; default="localhost")
      port <port> #(optional; default=27017)
    </match>

After that, you can start fluentd and everything should work:

    :::term
    $ fluentd -c fluentd.conf

Of course, this is just a quick example. If you are thinking of running fluentd in production, consider using [td-agent](//docs.treasure-data.com/articles/td-agent), the enterprise version of Fluentd packaged and maintained by [Treasure Data, Inc.](//www.treasure-data.com).
