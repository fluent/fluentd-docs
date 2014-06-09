# http Input Plugin

The `in_http` Input plugin enables Fluentd to retrieve records from HTTP POST. The URL path becomes the `tag` of the Fluentd event log and the POSTed body element becomes the record itself.

### Example Configuration

`in_http` is included in Fluentd's core. No additional installation process is required.

    :::text
    <source>
      type http
      port 8888
      bind 0.0.0.0
      body_size_limit 32m
      keepalive_timeout 10s
    </source>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

#### Example Usage

The example below posts a record using the `curl` command.

    :::term
    $ curl -X POST -d 'json={"action":"login","user":2}'
      http://localhost:8888/test.tag.here;

### Parameters

#### type (required)
The value must be `http`.

#### port
The port to listen to. Default Value = 9880

#### bind
The bind address to listen to. Default Value = 0.0.0.0 (all addresses)

#### body_size_limit
The size limit of the POSTed element. Default Value = 32MB

#### keepalive_timeout
The timeout limit for keeping the connection alive. Default Value = 10 seconds

#### add_http_headers
Add `HTTP_` prefix headers to the record. The default is `false`

#### format
The format of the HTTP body. The default is `default`.

* default

Accept records using `json=` / `msgpack=` style.

* regexp

Specify body format by regular expression.

    :::text
    format /^(?<field1>\d+):(?<field2>\w+)$/

If you execute following command:

    :::term
    $ curl -X POST -d '123456:awesome' "http://localhost:8888/test.tag.here"

then got parsed result like below:

    :::text
    {"field1":"123456","field2":"awesome}

`ltsv`, `tsv`, `csv` and `none` are also supported.


INCLUDE: _log_level_params


### time query parameter

If you want to pass the event time from your application, please use the `time` query parameter.

    :::term
    $ curl -X POST -d 'json={"action":"login","user":2}'
      "http://localhost:8888/test.tag.here?time=1392021185"

### Batch mode

If you use `default` format, then you can send array type of json / msgpack to in_http.

    :::term
    $ curl -X POST -d 'json=[{"action":"login","user":2,"time":1392021185},{"action":"logout","user":2,"time":1392027356}]'
      http://localhost:8888/test.tag.here;

Non `default` format doesn't support batch mode yet.
