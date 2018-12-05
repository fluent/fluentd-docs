# Getting Data From Json Into S3 Using Fluentd

Looking to get data out of json into s3? You can do that with [fluentd](//fluentd.org) in **10 minutes**!

<table>
  <td><img style="display:inline;width:250px" src="/images/plugin_icon/json.png"/></td>
  <td><span style="font-size:50px">&#8594;</span></td>
  <td><img style="display:inline;width:250px" src="/images/plugin_icon/s3.png"/></td>
</table>

Here is how:

    :::term
    $ gem install fluentd
    $ gem install fluent-plugin-s3
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
      type s3
      path <s3 path> #(optional; default="")
      time_format <format string> #(optional; default is ISO-8601)
      aws_key_id <Your AWS key id> #(required)
      aws_sec_key <Your AWS secret key> #(required)
      s3_bucket <s3 bucket name> #(required)
      s3_endpoint <s3 endpoint name> #(required; ex: s3-us-west-1.amazonaws.com)
      s3_object_key_format <format string> #(optional; default="%{path}%{time_slice}_%{index}.%{file_extension}")
      auto_create_bucket <true/false> #(optional; default=true)
      check_apikey_on_start <true/false> #(optional; default=true)
      proxy_uri <proxy uri string> #(optional)
    </match>

After that, you can start fluentd and everything should work:

    :::term
    $ fluentd -c fluentd.conf

Of course, this is just a quick example. If you are thinking of running fluentd in production, consider using [td-agent](//docs.treasure-data.com/articles/td-agent), the enterprise version of Fluentd packaged and maintained by [Treasure Data, Inc.](//www.treasure-data.com).
