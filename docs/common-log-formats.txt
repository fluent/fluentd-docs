# Common Log Formats and How To Parse Them

This page is a glossary of common log formats that can be parsed with the [Tail input plugin](in_tail).

* Apache Access Log

    Use `format apache2` as shown below:

        <source>
            type tail
            format apache2
            tag apache.access
            path /var/log/apache2/access.log
        </source>

* Apache Error Log

    Use a regular expression. See the `format` field in the following sample configuration.

        <source>
            type tail
            format /^\[[^ ]* (?<time>[^\]]*)\] \[(?<level>[^\]]*)\] \[pid (?<pid>[^\]]*)\] \[client (?<client>[^\]]*)\] (?<message>.*)$/
            tag apache.error
            path /var/log/apache2/error.log
        </source>

    Depending on your particular error log format, you may need to adjust the regular expression above. You can test your format using [Fluentular](http://fluentular.herokuapp.com).
    
* Maillog
    
    Use a regular expression. See the `format` field in the following sample configuration.

        <source>
            type tail
            format /^(?<time>[^ ]+) (?<host>[^ ]+) (?<process>[^:]+): (?<message>((?<key>[^ :]+)[ :])? ?((to|from)=<(?<address>[^>]+)>)?.*)$/
            tag postfix.maillog
            path /var/log/maillog
        </source>

* Nginx Access Log

    Use `format nginx` as shown below:

        <source>
            type tail
            format nginx
            tag nginx.access
            path /var/log/nginx/access.log
        </source>

* Nginx Error Log
    
    Use a regular expression. See the `format` field in the following sample configuration.

        <source>
            type tail
            format /^(?<time>[^ ]+ [^ ]+) \[(?<log_level>.*)\] (?<pid>\d*).(?<tid>[^:]*): (?<message>.*)$/
            tag nginx.error
            path /var/log/nginx/error.log
        </source>


* GlusterFS Logs

    Use the [GlusterFS input plugin.](collect-glusterfs-logs)

###Do you not see what you are looking for?

Give us a shout on [GitHub](https://github.com/fluent/fluentd-docs/issues?state=open), [Twitter](http://twitter.com/fluentd) or [the mailing list](https://groups.google.com/forum/#!forum/fluentd). Better yet, we always welcome a [pull request](https://github.com/fluent/fluentd-docs/pulls)!
