# Getting Data From Syslog Into Treasure Data Using Fluentd

Looking to get data out of syslog into treasure data? You can do that with [fluentd](//fluentd.org) in **10 minutes**!

<table>
  <td><img style="display:inline;width:250px" src="/images/plugin_icon/syslog.png"/></td>
  <td><span style="font-size:50px">&#8594;</span></td>
  <td><img style="display:inline;width:250px" src="/images/plugin_icon/treasure data.png"/></td>
</table>

Here is how:

    :::term
    $ gem install fluentd
    $ gem install fluent-plugin-td
    $ touch fluentd.conf

`fluentd.conf` should look like this (just copy and paste this into fluentd.conf):

    :::text
    <source>
      type syslog
      port 5140
      bind 0.0.0.0
      tag system.local
    </source>
    
    <match **>
      type tdlog
      apikey <Treasure Data API key> # You get your API key by signing up for Treasure Data
      auto_create_table
      buffer_type file
      buffer_path /var/log/td-agent/buffer/td
    </match>

After that, you can start fluentd and everything should work:

    :::term
    $ fluentd -c fluentd.conf

Of course, this is just a quick example. If you are thinking of running fluentd in production, consider using [td-agent](//docs.treasure-data.com/articles/td-agent), the enterprise version of Fluentd packaged and maintained by [Treasure Data, Inc.](//www.treasure-data.com).
