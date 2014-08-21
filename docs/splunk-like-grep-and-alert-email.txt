# Splunk-like Grep-and-Alert-Email System Using Fluentd

[Splunk](http://www.splunk.com/) is a great tool for searching logs. One of its key features is the ability to "grep" logs and send alert emails when certain conditions are met.

In this little "how to" article, we will show you how to build a similar system using Fluentd. More specifically, we will create a system that sends an alert email when it detects a 5xx HTTP status code in an Apache access log.

By the way, Splunk happens to be quite expensive. If you're interested in a free alternative, check out our article [here](free-alternative-to-splunk-by-fluentd).

## Installing the Needed Plugins

[Install](/categories/installation) Fluentd if you haven't yet.

Please install `fluent-plugin-grepcounter` by running:

    :::term
    $ gem install fluent-plugin-grepcounter

Next, please install `fluent-plugin-mail` by running:

    :::term
    $ gem install fluent-plugin-mail

## Configuration

###Configuration File: Soup to Nuts
Here is an example configuration file. It's a bit long, but each part is well-commented, so don't be afraid.

    :::text
    <source>
      type http #This is for testing
      port 8888
    </source>

    <source>
      type tail
      format apache2
      path /var/log/apache2/access.log #This is the location of your Apache log
      tag apache.access
    </source>
    
    <match apache.access>
      type grepcounter
      count_interval 3 #Time window to grep and count the # of events
      input_key code #We look at the (http status) "code" field
      regexp ^5\d\d$ #This regexp matches 5xx status codes
      threshold 1 #The # of events to trigger emitting an output
      add_tag_prefix error_5xx #The output event's tag will be error_5xx.apache.access
    </match>
    
    <match error_5xx.apache.access>
      # The event that comes here looks like
      #{
      #  "count":1,
      #  "input_tag":"error_5xx.apache.access",
      #  "input_tag_last":"access",
      #  "message":[500]
      #}

      type copy #Copying events, one to send to stdout, another for email alerts
      
      <store>
        type stdout
      </store>
      
      <store>
        type mail
        host smtp.gmail.com #This is for Gmail and Google Apps. Any SMTP server should work
        port 587 #This is the port for smtp.gmail.com
        user kiyoto@treasure-data.com #I work here! Use YOUR EMAIL.
        password XXXXXX #I can't tell you this! Use YOUR PASSWORD!
        enable_starttls_auto true
        from YOUR_SENDER_EMAIL_HERE
        to YOUR_RECIPIENT_EMAIL_HERE
        subject [URGENT] APACHE 5XX ERROR
        message Total 5xx error count: %s\n\nPlease check your Apache webserver ASAP
        message_out_keys count #The value of 'count' will be substituted into %s above.
      </store>
    </match>

Save the above into your own configuration file (**We assume it's called `test.conf` for the rest of this page**). Make sure your SMTP is configured correctly (otherwise, you will get a warning when you run the program).

###What the Configuration File Does

The config above does three things:

1. Sets up Fluentd to tail an Apache log file (located at `/var/log/apache2/access.log`).
2. Every 3 seconds, it counts the number of events whose "code" field is 5xx. If the number is at least 1 (because of `threshold 1`), emit an event with the tag `error_5xx.apache.access`. All of this is done by `fluent-plugin-grepcounter`.
3. Sends an email to dev@treasure-data.com (and also outputs to STDOUT for debugging & testing) for each event with the tag `error_5xx.apache.access`.

We can do all this **without writing a single line of code or paying a dime!**

##Testing

Just run

    :::term
    $ fluentd -c test.conf

to start Fluentd.

To trigger the alert email, you can either manually append a 5xx error log line to your Apache log or visit (on the same server)

    :::text
    http://localhost:8888/apache/access?json={"code":"500"}

(This uses the in_http plugin). You should be receiving an alert email with the subject line "[URGENT] APACHE 5XX ERROR" in your inbox right about now!

##What's Next?

Admittedly, this is a contrived example. In reality, you would set the threshold higher. Also, you might be interested in tracking 4xx pages as well. In addition to Apache logs, Fluentd can handle Nginx logs, syslogs, or any single- or multi-lined logs.

You can learn more about Fluentd and its plugins by

- exploring other [plugins](http://fluentd.org/plugin/)
- browsing [recipes](/categories/recipes)
- asking questions on the [mailing list](https://groups.google.com/forum/#!forum/fluentd)
- [signing up for our newsletters](http://get.treasuredata.com/Fluentd_education.html)
