# FAQ

## Known Issue

## What version of Ruby does fluentd support?

Fluentd v0.10 or v0.12 works on 1.9.3 or later. Since v0.14, 2.1 or later.

### I use Fluentd with Ruby 2.0 but Fluentd seems deadlocked. Why?

The rubygems of Ruby 2.0-p353 has a deadlock problem ([#9224](https://bugs.ruby-lang.org/issues/9224)).
If you use Ruby 2.0-p353, upgrading Ruby to latest patch level or Ruby 2.1 resolve this problem.

Unfortunately, Ruby 2.0 package of RHEL 7 and Ubuntu 14.04 use Ruby 2.0-p353.
So don't use Fluentd with Ruby 2.0 package on these environments.
You can install specified Ruby version using [rbenv](https://github.com/sstephenson/rbenv).

Using td-agent is another way to avoid this problem because td-agent includes own Ruby.

## Operations

### I have a weird timestamp value, what happened?

The timestamps of Fluentd and its logger libraries depend on your system's clock. It's highly recommended that you set up NTP on your nodes so that your clocks remain synced with the correct clocks.

### I installed td-agent and want to add custom plugins. How do I do it?

td-agent has own Ruby so you should install gems into td-agent's Ruby, not system Ruby.

#### td-agent 2:

Please use `td-agent-gem` as shown below.

    :::term
    $ /usr/sbin/td-agent-gem install <plugin name>

For example, issue the following command if you are adding `fluent-plugin-twitter`.

    :::term
    $ /usr/sbin/td-agent-gem install fluent-plugin-twitter

#### td-agent 1:

Please use `fluent-gem` as shown below.

    :::term
    $ /usr/lib/fluent/ruby/bin/fluent-gem install <plugin name>

For example, issue the following command if you are adding `fluent-plugin-twitter`.

    :::term
    $ /usr/lib/fluent/ruby/bin/fluent-gem install fluent-plugin-twitter

(If you can't find fluent-gem in the above directory, try looking in `/usr/lib64/fluent/ruby/bin/fluent-gem`)

Now you might be wondering, "Why do I need to specify the full path?" The reason is that td-agent does not modify any host environment variable, including `PATH`. If you want to make all td-agent/fluentd related programs available without writing "/usr/lib/..." every time, you can add

    :::bash
    export PATH=$PATH:/opt/td-agent/embedded/bin/ # td-agent 2
    export PATH=$PATH:/usr/lib/fluent/ruby/bin/   # td-agent 1

to your `~/.bash_profile`.

If you would like to find out more about plugin management, please take a look at the [Plugin Management](/articles/plugin-management) article.

### How can I match (send) an event to multiple outputs?

You can use the `copy` [output plugin](/articles/out_copy) to send the same event to multiple output destinations.

### How can I use environment variables to configure parameters dynamically?

Use `"#{ENV['YOUR_ENV_VARIABLE']}"`. For example,

    :::text
    some_field "#{ENV['FOO_HOME']}"

(Note that it must be double quotes and not single quotes)


## Plugin Development

### How do I develop a custom plugin?

Please refer to the [Plugin Development Guide](http://docs.fluentd.org/articles/plugin-development).

## HOWTOs

### How can I parse `<my complex text log>`?

If you are willing to write Regexp, [Fluentular](http://fluentular.herokuapp.com) is a great tool to verify your Regexps.

If you do NOT want to write any Regexp, look at [the Grok parser](https://github.com/kiyoto/fluent-plugin-grok-parser).
