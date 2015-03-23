# Multiprocess Input Plugin

By default, Fluentd only uses a single CPU core on the system. The `in_multiprocess` Input plugin enables Fluentd to use multiple CPU cores by spawning multiple child processes. One Fluentd user is using this plugin to handle 10+ billion records / day.

### Install

`in_multiprocess` is NOT included in td-agent by default. td-agent users must install fluent-plugin-multiprocess manually.

* Fluentd: `fluent-gem install fluent-plugin-multiprocess`
* td-agent v2: `/usr/sbin/td-agent-gem install fluent-plugin-multiprocess`
* td-agent v1: `/usr/lib/fluent/ruby/bin/fluent-gem install fluent-plugin-multiprocess`

### Example Configuration

    :::text
    <source>
      type multiprocess

      <process>
        cmdline -c /etc/fluent/fluentd_child1.conf --log /var/log/fluent/fluentd_child1.log
        sleep_before_start 1s
        sleep_before_shutdown 5s
      </process>
      <process>
        cmdline -c /etc/fluent/fluentd_child2.conf --log /var/log/fluent/fluentd_child2.log
        sleep_before_start 1s
        sleep_before_shutdown 5s
      </process>
      <process>
        cmdline -c /etc/fluent/fluentd_child3.conf --log /var/log/fluent/fluentd_child3.log
        sleep_before_start 1s
        sleep_before_shutdown 5s
      </process>
    </source>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

NOTE: Especially for daemonized fluentd (ex: td-agent), `--log` option MUST be specified to put logs of child processes.

### Parameters

#### type (required)
The value must be `multiprocess`.

#### graceful_kill_interval
The interval to send the signal to gracefully shut down the process (default: 2sec).

#### graceful_kill_interval_increment
The increment time, when graceful shutdown fails (default: 3sec).

#### graceful_kill_timeout
The timeout, to identify the failure of gracefull shutdown (default: 60sec).

#### process (required)
The `process` section sets the command line arguments of a child process. This plugin creates one child process for each <process> section.

#### cmdline (required)
The `cmdline` option is required in a <process> section

#### sleep_before_start
This parameter sets the wait time before starting the process (default: 0sec).

#### sleep_before_shutdown
This parameter sets the wait time before shutting down the process (default: 0sec).

INCLUDE: _log_level_params

