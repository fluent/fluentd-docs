# How To Filter Or Modify Data Inside Fluentd (Apache as an Example)

In this article, we introduce several common data manipulation challenges faced by our users (such as filtering and modifying data) and explain how to solve each task using one or more Fluentd plugins.

## Scenario: Filtering Data by the Value of a Field

Let's suppose our Fluentd instances are collecting data from Apache web server logs via [in_tail](in_tail). Our goal is to filter out all the 200 requests.

## Solution: Use fluent-plugin-grep

[fluent-plugin-grep](https://github.com/sonots/fluent-plugin-grep) is a plugin that can "grep" data according to the different fields within Fluentd events.

If our events looks like

    :::text
    {
        "code": 200,
        "url": "http://yourdomain.com/page.html",
        "size": 2344,
        "referer": "http://www.treasuredata.com"
        ...
    }

then we can filter out all the requests with status code 200 as follows:

    :::text
    ...
    <match apache.**>
        type grep
        input_key code
        exclude ^200$
        add_tag_prefix filtered
    </match>

By using the `add_tag_prefix` option, we can prepend a tag in front of filtered events so that they can be matched to a subsequent section. For example, we can send all logs with non-200 status codes to [Treasure Data](http://www.treasuredata.com), as shown below:

    :::text
    ...
    <match apache.**>
        type grep
        input_key code
        exclude ^200$
        add_tag_prefix filtered
    </match>
    <match filtered.apache.**>
        type td_log
        apikey XXXXX
        ...
    </match>

`fluent-plugin-grep` can filter based on multiple fields as well. The config below keeps all requests with status code 4xx that are NOT referred from yourdomain.com (a real world use case: figuring out how many dead links there are in the wild by filtering out internal links)

    :::text
    ...
    <match apache.**>
        type grep
        regexp1 code ^4\d\d$
        exclude1 referer ^https?://yourdomain.com
        add_tag_prefix external_dead_links
    </match>
    ...

## Scenario: Adding a New Field (such as hostname)

When collecting data, we often need to add a new field or change an existing field in our log data. For example, many Fluentd users need to add the hostname of their servers to the Apache web server log data in order to compute the number of requests handled by each server (i.e., store them in MongoDB/HDFS and run GROUP-BYs).

## Solution: Use fluent-plugin-record-modifier

[fluent-plugin-record-modifier](https://github.com/repeatedly/fluent-plugin-record-modifier) can add a new field to each data record.
    
If our events looks like

    {"code":200, "url":"http://yourdomain.com", "size":1232}

then we can add a new field with the hostname information as follows:

    :::text
    <match foo.bar>
        type record_modifier
        gen_host ${hostname}
        tag with_hostname
    </match>
    ...
    <match with_hostname>
        ...
    </match>

The modified events now look like

    {"gen_host": "our_server", code":200, "url":"http://yourdomain.com", "size":1232}

NOTE: The `${hostname}` placeholder is powered by [fluent-mixin-config-placeholder](https://github.com/tagomoris/fluent-mixin-config-placeholders). It inlines the host name of the server that the Fluentd instance is running on (in this example, our server's name is "our_server").
