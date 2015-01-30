# Life of a Fluentd Event

The following article describe a global overview of how events are processed by [Fluentd](http://fluentd.org) using examples. It covers the complete cycle including _Setup_, _Inputs_, _Filters_, _Matches_ and _Labels_.

## Basic Setup

As described in the articles above, the _Setup_ in the configuration files is the fundamental piece to connect all things together, as it allows to define which _Inputs_ or listeners [Fluentd](http://fluentd.org) will have and setup common matching rules to route the _Event_ data to a specific _Output_.

We will use the [in_http](in_http) and the [out_stdout](out_stdout) plugins as examples to describe the events cycle. The following is a basic definition on the configuration file to specify an _http_ input, for short: we will be listening for __HTTP Requests__:

    :::text
    <source>
      type http
      port 8888
      bind 0.0.0.0
    </source>

The definition specify that a HTTP server will be listening on TCP port 8888. Now lets define a _Matching_ rule and a desired output that will just print to the standard output the data that arrived on each incoming request:

    :::text
    <match test.cycle>
      type stdout
    </match>

The _Match_ sets a rule where each _Incoming_ event that arrives with a __Tag__ equals to _test\_cycle_, will match and use the _Output_ plugin type called _stdout_. At this point we have an _Input_ type, a _Match_ and an _Output_. Let's test the setup using _Curl_:

    :::text
    $ curl -i -X POST -d 'json={"action":"login","user":2}' http://localhost:9880/test.cycle
    HTTP/1.1 200 OK
    Content-type: text/plain
    Connection: Keep-Alive
    Content-length: 0

On the [Fluentd](http://fluentd.org) server side the output should look like this:

    :::text
    $ bin/fluentd -c in_http.conf
    2015-01-19 12:37:41 -0600 [info]: reading config file path="in_http.conf"
    2015-01-19 12:37:41 -0600 [info]: starting fluentd-0.12.3
    2015-01-19 12:37:41 -0600 [info]: using configuration file: <ROOT>
      <source>
        type http
        bind 0.0.0.0
        port 8888
      </source>
      <match test.cycle>
        type stdout
      </match>
    </ROOT>
    2015-01-19 12:37:41 -0600 [info]: adding match pattern="test.cycle" type="stdout"
    2015-01-19 12:37:41 -0600 [info]: adding source type="http"
    2015-01-19 12:39:57 -0600 test.cycle: {"action":"login","user":2}

## Processing Events

When a _Setup_ is defined, the _Router Engine_ already contains several rules to apply for different input data. Internally an _Event_ will to pass through a chain of procedures that may alter it cycle.

NOTE: starting from Fluentd v0.12 two new concepts were introduced to improve the routing behavior: Filters and Labels.

Now we will expand our previous basic example and we will add more steps in our _Setup_ to demonstrate how the _Events_ cycle can be altered. We will do this through the new _Filters_ implementation.

### Filters

A _Filter_ aims to behave like a rule to pass or reject an event. The following configuration adds a _Filter_ definition:

    :::text
    <source>
      type http
      port 8888
      bind 0.0.0.0
    </source>

    <filter test.cycle>
      type grep
      exclude1 action logout
    </filter>

    <match test.cycle>
      type stdout
    </match>

As you can see, the new _Filter_ definition added will be a mandatory step before to pass the control to the _Match_ section. The _Filter_ basically will accept or reject the _Event_ based on it _type_ and rule defined. For our example we want to discard any user _logout_ action, we will care just about the _logins_. The way to accomplish this, is doing a _grep_ inside the _Filter_ that states that will exclude any message on which _action_ key have the _logout_ string.

From a _Terminal_, run the following two _Curl_ commands, please note that each one contains a different _action_ value:

    :::text
    $ curl -i -X POST -d 'json={"action":"login","user":2}' http://localhost:8880/test.cycle
    HTTP/1.1 200 OK
    Content-type: text/plain
    Connection: Keep-Alive
    Content-length: 0

    $ curl -i -X POST -d 'json={"action":"logout","user":2}' http://localhost:8880/test.cycle
    HTTP/1.1 200 OK
    Content-type: text/plain
    Connection: Keep-Alive
    Content-length: 0

Now looking at the [Fluentd](http://fluentd.org) service output we can realize that just the one with the _action_ equals to _login_ just matched. The _logout_ _Event_ was discarded:

    :::text
    $ bin/fluentd -c in_http.conf
    2015-01-19 12:37:41 -0600 [info]: reading config file path="in_http.conf"
    2015-01-19 12:37:41 -0600 [info]: starting fluentd-0.12.4
    2015-01-19 12:37:41 -0600 [info]: using configuration file: <ROOT>
    <source>
      type http
      bind 0.0.0.0
      port 9880
    </source>
    <filter test.cycle>
      type grep
      exclude1 action logout
    </filter>
    <match test.cycle>
      type stdout
    </match>
    </ROOT>
    2015-01-19 12:37:41 -0600 [info]: adding filter pattern="test.cycle" type="grep"
    2015-01-19 12:37:41 -0600 [info]: adding match pattern="test.cycle" type="stdout"
    2015-01-19 12:37:41 -0600 [info]: adding source type="http"
    2015-01-27 01:27:11 -0600 test.cycle: {"action":"login","user":2}

As you can see, the _Events_ follow a _step by step cycle_ where they are processed in order from top to bottom. The new engine on [Fluentd](http://fluentd.org) allows to integrate many _Filters_ as necessary, also considering that the configuration file will grow and start getting a bit complex for the readers, a new feature called _Labels_ have been added that aims to solve this possible problem.

### Labels

This new implementation called _Labels_, aims to solve the configuration file complexity and allows to define new _Routing_ sections that do not follow the _top to bottom_ order, instead it acts like linked references. Talking the previous example, we will modify the setup as follows:

    :::text
    <source>
      type http
      bind 0.0.0.0
      port 8880
      @label @STAGING
    </source>

    <filter test.cycle>
      type grep
      exclude1 action login
    </filter>

    <label @STAGING>
      <filter test.cycle>
        type grep
        exclude1 action logout
      </filter>

      <match test.cycle>
        type stdout
      </match>
    </label>

The new configuration contains a _@label_ key on the _source_ indicating that any further steps takes place on the _STAGING_ _Label_ section. The expectation is that every _Event_ reported on the _Source_, the _Routing_ engine will continue processing on _STAGING_, for hence it will skip the old filter definition.

## Conclusion

Once the events are reported by the [Fluentd](http://fluend.org) engine on the _Source_, can be processed _step by step_ or inside a referenced _Label_, as well any _Event_ may be filtered out at any moment. The new _Routing_ engine behavior aims to provide more flexibility and makes easier the processing before reaching the _Output_ plugin.

## Learn More

* [Fluentd v0.12 Blog Announcement](http://www.fluentd.org/blog/fluentd-v0.12-is-released)
