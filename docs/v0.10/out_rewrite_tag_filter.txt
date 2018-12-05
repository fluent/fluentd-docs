# rewrite_tag_filter Output Plugin

The `out_rewrite_tag_filter` Output plugin has designed to rewrite tag like mod_rewrite. Re-emit a record with rewrited tag when a value matches/unmatches with the regular expression.  Also you can change a tag from apache log by domain, status-code(ex. 500 error), user-agent, request-uri, regex-backreference and so on with regular expression. 

## How it works

It is a sample to arrange the tags by the regexp matched value of 'message'.

    :::text
    # Configuration
    <match app.message>
      type rewrite_tag_filter
      rewriterule1 message ^\[(\w+)\] $1.${tag}
    </match>

    :::text
    +----------------------------------------+        +----------------------------------------------+
    | original record                        |        | rewrited tag record                          |
    |----------------------------------------|        |----------------------------------------------|
    | app.message {"message":"[info]: ..."}  | +----> | info.app.message {"message":"[info]: ..."}   |
    | app.message {"message":"[warn]: ..."}  | +----> | warn.app.message {"message":"[warn]: ..."}   |
    | app.message {"message":"[crit]: ..."}  | +----> | crit.app.message {"message":"[crit]: ..."}   |
    | app.message {"message":"[alert]: ..."} | +----> | alert.app.message {"message":"[alert]: ..."} |
    +----------------------------------------+        +----------------------------------------------+

## Install

`out_rewrite_tag_filter` is included in td-agent by default (v1.1.18 or later). Fluentd gem users will have to install the fluent-plugin-rewrite-tag-filter gem using the following command.

    :::term
    $ fluent-gem install fluent-plugin-rewrite-tag-filter

## Example Configuration

Configuration design is dropping some pattern record first, then re-emit other matched record as new tag name.

    :::text
    <match apache.access>
      type rewrite_tag_filter
      capitalize_regex_backreference yes
      rewriterule1 path   \.(gif|jpe?g|png|pdf|zip)$  clear
      rewriterule2 status !^200$                      clear
      rewriterule3 domain !^.+\.com$                  clear
      rewriterule4 domain ^maps\.example\.com$        site.ExampleMaps
      rewriterule5 domain ^news\.example\.com$        site.ExampleNews
      # it is also supported regexp back reference.
      rewriterule6 domain ^(mail)\.(example)\.com$    site.$2$1
      rewriterule7 domain .+                          site.unmatched
    </match>

    <match clear>
      type null
    </match>

NOTE: Please see the <a href="https://github.com/fluent/fluent-plugin-rewrite-tag-filter">README.md</a> for further details.

## Parameters

### rewriteruleN (required at least one)

`rewriterule<num> <key> <regex_pattern> <new_tag>`

NOTE: It works with the order &lt;num&gt; ascending, regexp matching &lt;regex_pattern&gt; for the values of &lt;key&gt; from each record, re-emit with &lt;new_tag&gt;.

### capitalize_regex_backreference
Capitalize letter for every matched regex backreference. (ex: maps -> Maps)

### hostname_command
Override hostname command for placeholder. (default setting is long hostname)

INCLUDE: _log_level_params


## Placeholders

It is supported these placeholder for new_tag (rewrited tag). See more details at <a href="https://github.com/fluent/fluent-plugin-rewrite-tag-filter#tag-placeholder">README.md</a>

* ${tag}
* __TAG__
* {$tag_parts[n]}
* __TAG_PARTS[n]__
* ${hostname}
* __HOSTNAME__

## Use cases

* Aggregate + display 404 status pages by URL and referrer to find and fix dead links.
* Send an IRC alert for 5xx status codes on exceeding thresholds.

#### Aggregate + display 404 status pages by URL and referrer to find and fix dead links.

* Collect access log from multiple application servers (config1)
* Sum up the 404 error and output to mongoDB (config2)

Note: These plugins are required to be installed.
* fluent-plugin-rewrite-tag-filter
* fluent-plugin-mongo

##### [Config1] Application Servers

    :::text
    # Input access log to fluentd with embedded in_tail plugin
    <source>
      type tail
      path /var/log/httpd/access_log
      format apache2
      time_format %d/%b/%Y:%H:%M:%S %z
      tag apache.access
      pos_file /var/log/td-agent/apache_access.pos
    </source>

    # Forward to monitoring server
    <match apache.access>
      type forward
      flush_interval 5s
      <server>
        name server_name
        host 10.100.1.20
      </server>
    </match>


##### [Config2] Monitoring Server

    :::text
    # built-in TCP input
    <source>
      type forward
    </source>

    # Filter record like mod_rewrite with fluent-plugin-rewrite-tag-filter
    <match apache.access>
      type rewrite_tag_filter
      rewriterule1 status ^(?!404)$ clear
      rewriterule2 path .+ mongo.apache.access.error404
    </match>

    # Store deadlinks log into mongoDB
    <match mongo.apache.access.error404>
      type        mongo
      host        10.100.1.30
      database    apache
      collection  deadlinks
      capped
      capped_size 50m
    </match>

    # Clear tag
    <match clear>
      type null
    </match>


#### Send an IRC alert for 5xx status codes on exceeding thresholds.

* Collect access log from multiple application servers (config1)
* Sum up the 500 error and notify IRC and logging details to mongoDB (config2)

Note: These plugins are required to be installed.
* fluent-plugin-rewrite-tag-filter
* fluent-plugin-datacounter
* fluent-plugin-notifier
* fluent-plugin-parser
* fluent-plugin-mongo
* fluent-plugin-irc

##### [Config1] Application Servers

    :::text
    # Input access log to fluentd with embedded in_tail plugin
    # sample results: {"host":"127.0.0.1","user":null,"method":"GET","path":"/","code":500,"size":5039,"referer":null,"agent":"Mozilla"}
    <source>
      type tail
      path /var/log/httpd/access_log
      format apache2
      time_format %d/%b/%Y:%H:%M:%S %z
      tag apache.access
      pos_file /var/log/td-agent/apache_access.pos
    </source>

    # Forward to monitoring server
    <match apache.access>
      type forward
      flush_interval 5s
      <server>
        name server_name
        host 10.100.1.20
      </server>
    </match>


##### [Config2] Monitoring Server

    :::text
    # built-in TCP input
    <source>
      type forward
    </source>

    # Filter record like mod_rewrite with fluent-plugin-rewrite-tag-filter
    <match apache.access>
      type copy
      <store>
      type rewrite_tag_filter
      # drop static image record and redirect as 'count.apache.access'
      rewriterule1 path ^/(img|css|js|static|assets)/ clear
      rewriterule2 path .+ count.apache.access
      </store>
      <store>
      type rewrite_tag_filter
      rewriterule1 code ^5\d\d$ mongo.apache.access.error5xx
      </store>
    </match>

    # Store 5xx error log into mongoDB
    <match mongo.apache.access.error5xx>
      type        mongo
      host        10.100.1.30
      database    apache
      collection  error_5xx
      capped
      capped_size 50m
    </match>

    # Count by status code
    # sample results: {"unmatched_count":0,"unmatched_rate":0.0,"unmatched_percentage":0.0,"200_count":0,"200_rate":0.0,"200_percentage":0.0,"2xx_count":0,"2xx_rate":0.0,"2xx_percentage":0.0,"301_count":0,"301_rate":0.0,"301_percentage":0.0,"302_count":0,"302_rate":0.0,"302_percentage":0.0,"3xx_count":0,"3xx_rate":0.0,"3xx_percentage":0.0,"403_count":0,"403_rate":0.0,"403_percentage":0.0,"404_count":0,"404_rate":0.0,"404_percentage":0.0,"410_count":0,"410_rate":0.0,"410_percentage":0.0,"4xx_count":0,"4xx_rate":0.0,"4xx_percentage":0.0,"5xx_count":1,"5xx_rate":0.01,"5xx_percentage":100.0}
    <match count.apache.access>
      type datacounter
      unit minute
      outcast_unmatched false
      aggregate all
      tag threshold.apache.access
      count_key code
      pattern1 200 ^200$
      pattern2 2xx ^2\d\d$
      pattern3 301 ^301$
      pattern4 302 ^302$
      pattern5 3xx ^3\d\d$
      pattern6 403 ^403$
      pattern7 404 ^404$
      pattern8 410 ^410$
      pattern9 4xx ^4\d\d$
      pattern10 5xx ^5\d\d$
    </match>

    # Determine threshold
    # sample results: {"pattern":"code_500","target_tag":"apache.access","target_key":"5xx_count","check_type":"numeric_upward","level":"warn","threshold":1.0,"value":1.0,"message_time":"2014-01-28 16:47:39 +0900"}
    <match threshold.apache.access>
      type notifier
      input_tag_remove_prefix threshold
      <def>
        pattern code_500
        check numeric_upward
        warn_threshold  10
        crit_threshold  40
        tag alert.http_5xx_error
        target_key_pattern ^5xx_count$
      </def>
    </match>

    # Generate message
    # sample results: {"message":"HTTP Status warn [5xx_count] apache.access: 1.0 (threshold 1.0)"}
    <match alert.http_5xx_error>
      type deparser
      tag irc.http_5xx_error>
      format_key_names level,target_key,target_tag,value,threshold
      format HTTP Status %s [%s] %s: %s (threshold %s)
      key_name message
      reserve_data no
    </match>

    # Send IRC message
    <match irc.http_5xx_error>
      type irc
      host localhost
      port 6667
      channel fluentd
      nick fluentd
      user fluentd
      real fluentd
      message %s
      out_keys message
    </match>

    # Clear tag
    <match clear>
      type null
    </match>
