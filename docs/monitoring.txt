# Monitoring Fluentd

This article explains how to monitor the `Fluentd` daemon.

## Monitoring Agent

Fluentd has a monitoring agent to retrieve internal metrics in JSON via HTTP. Please add the following lines to your configuration file.

    :::text
    <source>
      type monitor_agent
      bind 0.0.0.0
      port 24220
    </source>

Next, please restart the agent and get the metrics via HTTP.

    :::term
    $ curl http://host:24220/api/plugins.json
    {"plugins":[{"plugin_id":"object:3fec669d6ac4","type":"forward","output_plugin":false,"config":{"type":"forward"}},{"plugin_id":"object:3fec669daf98","type":"http","output_plugin":false,"config":{"type":"http","port":"8888"}},{"plugin_id":"object:3fec669dfa48","type":"monitor_agent","output_plugin":false,"config":{"type":"monitor_agent","port":"24220"}},{"plugin_id":"object:3fec66a52e94","type":"debug_agent","output_plugin":false,"config":{"type":"debug_agent","port":"24230"}},{"plugin_id":"object:3fec66ae3dcc","type":"stdout","output_plugin":true,"config":{"type":"stdout"}},{"plugin_id":"object:3fec66aead48","type":"forward","output_plugin":true,"buffer_queue_length":0,"buffer_total_queued_size":0,"retry_count":0,"config":{"type":"forward","host":"192.168.0.11"}}]}%

## Process Monitoring

Two `ruby` processes (parent and child) are executed. Please make sure that these processes are running. The example for `td-agent` is shown below.

    :::term
    /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent
      --daemon /var/run/td-agent/td-agent.pid
      --log /var/log/td-agent/td-agent.log

For td-agent on Linux, you can check the process statuses with the following command. Two processes should be shown if there are no issues.

    $ ps w -C ruby -C td-agent --no-heading
    32342 ?        Sl     0:00 /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --daemon /var/run/td-agent/td-agent.pid --log /var/log/td-agent/td-agent.log
    32345 ?        Sl     0:01 /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent --daemon /var/run/td-agent/td-agent.pid --log /var/log/td-agent/td-agent.log

If you are using td-agent 1, Ruby's path is `/usr/lib/fluent/ruby/bin/ruby`, not `/opt/td-agent/embedded/bin/ruby`.

## Port Monitoring

Fluentd opens several ports according to the configuration file. We recommend checking the availability of these ports. The default port settings are shown below:

* TCP 0.0.0.0 9880 (HTTP by default)
* TCP 0.0.0.0 24224 (Forward by default)

### Debug Port

A debug port for local communication is recommended for trouble shooting. Please note that the configuration below will be required.

    :::text
    <source>
      type debug_agent
      bind 127.0.0.1
      port 24230
    </source>

You can attach the process using the `fluent-debug` command through dRuby.

