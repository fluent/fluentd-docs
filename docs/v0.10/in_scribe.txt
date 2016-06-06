# scribe Input Plugin

The `in_scribe` Input plugin enables Fluentd to retrieve records through the Scribe protocol. [Scribe](https://github.com/facebook/scribe) is another log collector daemon that is open-sourced by Facebook.

Since Scribe hasn't been well maintained recently, this plugin is useful for existing Scribe users who want to use Fluentd with an existing Scribe infrastructure.

### Install

`in_scribe` is included in td-agent by default. Fluentd gem users will need to install the fluent-plugin-scribe gem using the following command.

    :::term
    $ fluent-gem install fluent-plugin-scribe

### Example Configuration

    :::text
    <source>
      type scribe
      port 1463

      bind 0.0.0.0
      msg_format json
    </source>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

#### Example Usage

We assume that you're already familiar with the Scribe protocol. This [Ruby example code](https://github.com/fluent/fluent-plugin-scribe/blob/master/bin/fluent-scribe-remote) posts logs to `in_scribe`.

Scribe's `category` field becomes the `tag` of the Fluentd event log and Scribe's `message` field becomes the record itself. The `msg_format` parameter specifies the format of the `message` field.

### Parameters

#### type (required)
The value must be `scribe`.

#### port
The port to listen to. Default Value = 1463

#### bind
The bind address to listen to. Default Value = 0.0.0.0 (all addresses)

#### msg_format

The message format can be ‘text’, ‘json’, or ‘url_param’ (default: text)

For `json`, Fluentd's record is organized as follows. Scribe's message field must be a valid JSON string representing Hash; otherwise, the record is ignored.

    tag: $category
    record: $message

For `text`, Fluentd's record is organized as follows. Scribe's message can be any arbitrary string, but JSON is recommended for ease of use with the subsequent analytics pipeline.

    tag: $category
    record: {'message': $message}

For `url_param`, Fluentd's record is organized as follows. Scribe's message field must contain URL parameter style key-value pairs with URL encoding (e.g. key1=val1&key2=val2).

    tag: $url_param
    record: {$key1: $val1, $key2: $val2, ...}

#### is_framed
Specifies whether to use Thrift's framed protocol or not (default: true).

#### server_type
Chooses the server architecture. Options are ‘simple’, ‘threaded’, ‘thread_pool’, or ‘nonblocking’ (default: nonblocking).

####  add_prefix
The prefix string which will always be added to the tag (default: nil).

INCLUDE: _log_level_params

