# Writing plugins

## Installing custom plugins

To install a plugin, please put the ruby script in the ``/etc/fluent/plugin`` directory.

Alternatively, you can create a Ruby Gem package that includes a ``lib/fluent/plugin/<TYPE>_<NAME>.rb`` file. The *TYPE* is:

- ``in`` for input plugins
- ``out`` for output plugins
- ``filter`` for filter plugins
- ``buf`` for buffer plugins
- ``parser`` for parser plugins
- ``formatter`` for formatter plugins

For example, an email Output plugin would have the path: ``lib/fluent/plugin/out_mail.rb``. The packaged gem can be distributed and installed using RubyGems. For further information, please see the [list of Fluentd plugins](http://www.fluentd.org/plugins) for third-party plugins.

## Overview

The following slides can help the user understand how Fluentd works before they dive into writing their own plugins.

<iframe src="//www.slideshare.net/slideshow/embed_code/39324320?startSlide=9" width="427" height="356" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe>

(The slides are taken from <a href="//github.com/sonots">Naotoshi Seo's</a> <a href="//rubykaigi.org/2014/presentation/S-NaotoshiSeo">RubyKaigi 2014 talk</a>.)

## Writing Input Plugins

Extend the **Fluent::Input** class and implement the following methods.

    :::ruby
    module Fluent
      class SomeInput < Input
        # First, register the plugin. NAME is the name of this plugin
        # and identifies the plugin in the configuration file.
        Fluent::Plugin.register_input('NAME', self)
  
        # config_param defines a parameter. You can refer a parameter via @port instance variable
        # :default means this parameter is optional
        config_param :port, :integer, :default => 8888
  
        # This method is called before starting.
        # 'conf' is a Hash that includes configuration parameters.
        # If the configuration is invalid, raise Fluent::ConfigError.
        def configure(conf)
          super
  
          # You can also refer to raw parameter via conf[name].
          @port = conf['port']
          ...
        end
  
        # This method is called when starting.
        # Open sockets or files and create a thread here.
        def start
          super
          ...
        end
  
        # This method is called when shutting down.
        # Shutdown the thread and close sockets or files here.
        def shutdown
          ...
        end
      end
    end

To submit events, use the ``Fluent::Engine.emit(tag, time, record)`` method, where ``tag`` is the String, ``time`` is the UNIX time integer and ``record`` is a Hash object.

    :::ruby
    tag = "myapp.access"
    time = Engine.now
    record = {"message"=>"body"}
    Fluent::Engine.emit(tag, time, record)

### Record format

Fluentd plugins assume the record is a JSON so the key should be the String, not Symbol.
If you emit a symbol keyed record, it may cause a problem.

    :::ruby
    Fluent::Engine.emit(tag, time, {'foo' => 'bar'})  # OK!
    Fluent::Engine.emit(tag, time, {:foo => 'bar'})   # NG!

## Writing Buffered Output Plugins

Extend the **Fluent::BufferedOutput** class and implement the following methods.

    :::ruby
    module Fluent
      class SomeOutput < BufferedOutput
        # First, register the plugin. NAME is the name of this plugin
        # and identifies the plugin in the configuration file.
        Fluent::Plugin.register_output('NAME', self)
  
        # config_param defines a parameter. You can refer a parameter via @path instance variable
        # Without :default, a parameter is required.
        config_param :path, :string
  
        # This method is called before starting.
        # 'conf' is a Hash that includes configuration parameters.
        # If the configuration is invalid, raise Fluent::ConfigError.
        def configure(conf)
          super
  
          # You can also refer raw parameter via conf[name].
          @path = conf['path']
          ...
        end
  
        # This method is called when starting.
        # Open sockets or files here.
        def start
          super
          ...
        end
  
        # This method is called when shutting down.
        # Shutdown the thread and close sockets or files here.
        def shutdown
          super
          ...
        end
  
        # This method is called when an event reaches to Fluentd.
        # Convert the event to a raw string.
        def format(tag, time, record)
          [tag, time, record].to_json + "\n"
          ## Alternatively, use msgpack to serialize the object.
          # [tag, time, record].to_msgpack
        end
  
        # This method is called every flush interval. Write the buffer chunk
        # to files or databases here.
        # 'chunk' is a buffer chunk that includes multiple formatted
        # events. You can use 'data = chunk.read' to get all events and
        # 'chunk.open {|io| ... }' to get IO objects.
        #
        # NOTE! This method is called by internal thread, not Fluentd's main thread. So IO wait doesn't affect other plugins.
        def write(chunk)
          data = chunk.read
          print data
        end
  
        ## Optionally, you can use chunk.msgpack_each to deserialize objects.
        #def write(chunk)
        #  chunk.msgpack_each {|(tag,time,record)|
        #  }
        #end
      end
    end


## Writing Time Sliced Output Plugins

Time Sliced Output plugins are extended versions of buffered output plugins. One example of a time sliced output is the ``out_file`` plugin.

Note that Time Sliced Output plugins use file buffer by default. Thus the ``buffer_path`` option is required.

To implement a Time Sliced Output plugin, extend the **Fluent::TimeSlicedOutput** class and implement the following methods.

    :::ruby
    module Fluent
      class SomeOutput < TimeSlicedOutput
        # configure(conf), start(), shutdown() and format(tag, time, record) are
        # the same as BufferedOutput.
        ...
  
        # You can use 'chunk.key' to get sliced time. The format of 'chunk.key'
        # can be configured by the 'time_format' option. The default format is %Y%m%d.
        def write(chunk)
          day = chunk.key
          ...
        end
      end


## Writing Non-buffered Output Plugins

Extend the **Fluent::Output** class and implement the following methods. **Output** plugin is often used for implementing filter like plugin.

    :::ruby
    module Fluent
      class SomeOutput < Output
        # First, register the plugin. NAME is the name of this plugin
        # and identifies the plugin in the configuration file.
        Fluent::Plugin.register_output('NAME', self)
  
        # This method is called before starting.
        def configure(conf)
          super
          ...
        end
      
        # This method is called when starting.
        def start
          super
          ...
        end
      
        # This method is called when shutting down.
        def shutdown
          super
          ...
        end
      
        # This method is called when an event reaches Fluentd.
        # 'es' is a Fluent::EventStream object that includes multiple events.
        # You can use 'es.each {|time,record| ... }' to retrieve events.
        # 'chain' is an object that manages transactions. Call 'chain.next' at
        # appropriate points and rollback if it raises an exception.
        #
        # NOTE! This method is called by Fluentd's main thread so you should not write slow routine here. It causes Fluentd's performance degression.
        def emit(tag, es, chain)
          chain.next
          es.each {|time,record|
            $stderr.puts "OK!"
          }
        end
      end
    end

## Filter Plugins

This section shows how to write custom filters in addition to [the core filter plugins](filter-plugin-overview). The plugin files whose names start with "filter_" are registered as filter plugins.

Here is the implementation of the most basic filter that passes through all events as-is:

    :::ruby
    module Fluent
      class PassThruFilter < Filter
    
        # config_param works like other plugins

        def configure(conf)
          super
          # do the usual configuration here
        end

        def start
          super
          # This is the first method to be called when it starts running
          # Use it to allocate resources, etc.
        end

        def shutdown
          super
          # This method is called when Fluentd is shutting down.
          # Use it to free up resources, etc.
        end

        def filter(tag, time, record)
          # This method implements the filtering logic for individual filters
          # It is internal to this class and called by filter_stream unless
          # the user overrides filter_stream.
          #
          # Since our example is a pass-thru filter, it does nothing and just
          # returns the record as-is.
          record
        end
      end
    end


## Parser Plugins

Fluentd supports [pluggable, customizable formats for input plugins](parser-plugin-overview). The plugin files whose names start with "parser_" are registered as Parser Plugins.

Here is an example of a custom parser that parses the following newline-delimited log format:

    :::text
    <timestamp><SPACE>key1=value1<DELIMITER>key2=value2<DELIMITER>key3=value...

e.g., something like this

    :::text
    2014-04-01T00:00:00 name=jake age=100 action=debugging

While it is not hard to write a regular expression to match this format, it is tricky to extract and save key names.

Here is the code to parse this custom format (let's call it `time_key_value`). It takes one optional parameter called `delimiter`, which is the delimiter for key-value pairs. It also takes `time_format` to parse the time string.

    :::ruby
    module Fluent
      class TextParser
        class TimeKeyValueParser < Parser
          # Register this parser as "time_key_value"
          Plugin.register_parser("time_key_value", self)

          config_param :delimiter, :string, :default => " " # delimiter is configurable with " " as default
          config_param :time_format, :string, :default => nil # time_format is configurable
          # This method is called after config_params have read configuration parameters
          def configure(conf)
            if @delimiter.length != 1
              raise ConfigError, "delimiter must be a single character. #{@delimiter} is not."
            end

            # TimeParser class is already given. It takes a single argument as the time format
            # to parse the time string with.
            @time_parser = TimeParser.new(@time_format)
          end
          
          # This is the main method. The input "text" is the unit of data to be parsed.
          # If this is the in_tail plugin, it would be a line. If this is for in_syslog,
          # it is a single syslog message.
          def call(text)
            time, key_values = text.split(" ", 2)
            time = @time_parser.parse(time)
            record = {}
            key_values.split(@delimiter).each { |kv|
              k, v = kv.split("=", 2)
              record[k] = v
            }
            yield time, record
          end
        end
      end
    end

Then, save this code in `parser_time_key_value.rb` in a loadable plugin path. Then, if in_tail is configured as

    :::text
    # Other lines...
    <source>
      type tail
      path /path/to/input/file
      format time_key_parser
    </source>

Then, the log line like `2014-01-01T00:00:00 k=v a=b` is parsed as `2013-01-01 00:00:00 +0000 test: {"k":"v","a":"b"}`.

## Text Formatter Plugins

Fluentd supports [pluggable, customizable formats for output plugins](formatter-plugin-overview). The plugin files whose names start with "formatter_" are registered as Formatter Plugins.

Here is an example of a custom formatter that outputs events as CSVs. It takes a required parameter called "csv_fields" and outputs the fields. It assumes that the values of the fields are already valid CSV fields.

    :::ruby
    module Fluent
      module TextFormatter
        class MyCSVFormatter < Formatter
          # Register MyCSVFormatter as "my_csv".
          Plugin.register_formatter("my_csv", self)

          include HandleTagAndTimeMixin # If you wish to use tag_key, time_key, etc.          
          config_param :csv_fields, :string
          
          # This method does further processing. Configuration parameters can be
          # accessed either via "conf" hash or member variables.
          def configure(conf)
            super
            @csv_fields = conf['csv_fields'].split(",")
          end
          
          # This is the method that formats the data output.
          def format(tag, time, record)
            values = []
            
            # Look up each required field and collect them from the record
            @csv_fields.each do |field|
              v = record[field]
              if not v
                $log.error "#{field} is missing."
              end
              values << v
            end
            
            # Output by joining the fields with a comma
            values.join(",")
          end
        end        
      end
    end

Then, save this code in `formatter_my_csv.rb` in a loadable plugin path. Then, if out_file is configured as

    :::text
    # Other lines...
    <match test>
      type file
      path /path/to/output/file
      format my_csv
      csv_fields k1,k2
    </match>

and if the record `{"k1": 100, "k2": 200}` is matched, the output file should look like `100,200`

## Debugging plugins

Run ``fluentd`` with the ``-vv`` option to show debug messages:

    :::term
    $ fluentd -vv

The **stdout** and **copy** output plugins are useful for debugging. The **stdout** output plugin dumps matched events to the console. It can be used as follows:

    :::text
    # You want to debug this plugin.
    <source>
      type your_custom_input_plugin
    </source>
    
    # Dump all events to stdout.
    <match **>
      type stdout
    </match>

The **copy** output plugin copies matched events to multiple output plugins. You can use it in conjunction with the stdout plugin:

    :::text
    <source>
      type tcp
    </source>

    # Use the tcp Input plugin and the fluent-cat command to feed events:
    #  $ echo '{"event":"message"}' | fluent-cat test.tag
    <match test.tag>
      type copy

      # Dump the matched events.
      <store>
        type stdout
      </store>

      # Feed the dumped events to your plugin.
      <store>
        type your_custom_output_plugin
      </store>
    </match>

## Writing test cases

Fluentd provides unit test frameworks for plugins:

    :::text
    Fluent::Test::InputTestDriver
      Test driver for input plugins.
    
    Fluent::Test::BufferedOutputTestDriver
      Test driver for buffered output plugins.
    
    Fluent::Test::OutputTestDriver
      Test driver for non-buffered output plugins.

Please see Fluentd's source code for details.

## Further Reading

* [Slides: Dive into Fluentd Plugin](http://www.slideshare.net/repeatedly/fluentd-meetup-dive-into-fluent-plugin)
