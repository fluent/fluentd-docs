# Troubleshooting Fluentd

## Look at Logs

If things aren't happening as expected, please first look at your logs. For td-agent (rpm/deb), the logs are located at `/var/log/td-agent/td-agent.log`.

## Turn on Verbose Logging

You can get more information about the logs if verbose logging is turned on. Please follow the steps below.

### rpm

1. edit `/etc/init.d/td-agent`
2. add `-vv` to TD_AGENT_ARGS
3. restart td-agent

        # at /etc/init.d/td-agent
        ...
        TD_AGENT_ARGS="... -vv"
        ...

### deb

1. edit `/etc/init.d/td-agent`
2. add `-vv` to DAEMON_ARGS
3. restart td-agent

        # at /etc/init.d/td-agent
        ...
        DAEMON_ARGS="... -vv"
        ...

### gem

Please add `-vv` to your command line.

    :::text
    $ fluentd .. -vv
