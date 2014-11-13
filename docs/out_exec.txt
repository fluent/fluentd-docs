# exec Output Plugin

The `out_exec` TimeSliced Output plugin passes events to an external program. The program receives the path to a file containing the incoming events as its last argument. The file format is tab-separated values (TSV) by default.

## Example Configuration

`out_exec` is included in Fluentd's core. No additional installation process is required.

    :::text
    <match pattern>
      type exec
      command cmd arg arg
      format tsv
      keys k1,k2,k3
      tag_key k1
      time_key k2
      time_format %Y-%m-%d %H:%M:%S
    </match>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.


## Example: Running FizzBuzz against data stream

This example illustrates how to run FizzBuzz with out_exec.

We assume that the input file is specified by the last argument in the command line ("ARGV[-1]"). The following script `fizzbuzz.py` runs [FizzBuzz](http://en.wikipedia.org/wiki/Fizz_buzz) against the new-line delimited sequence of natural numbers (1, 2, 3...) and writes the output to "foobar.out".

    :::text
    #!/usr/bin/env python
    import sys
    input = file(sys.argv[-1])
    output = file("foobar.out", "a")
    for line in input:
        fizzbuzz = int(line.split("\t")[0])
		s = ''
        if fizzbuzz%3 == 0:
            s += 'fizz'
        if fizzbuzz%5 == 0:
            s += 'buzz'
        if len(s) > 0:
		    output.write(s+"\n")
	    else:
	        output.write(str(fizzbuzz)+"\n")
    output.close

Note that this program is written in Python. For out_exec (as well as out_exec_filter and in_exec), **the program can be written in any language, not just Ruby.**

Then, configure Fluentd as follows

    :::text
    <source>
	  type forward
	</source>
    <match fizzbuzz>
	  type exec
	  command python /path/to/fizzbuzz.py
      buffer_path    /path/to/buffer_path
	  format tsv
	  keys fizzbuzz
	  flush_interval 5s # for debugging/checking
	</match>

The "format tsv" and "keys fizzbuzz" tells Fluentd to extract the "fizzbuzz" field and output it as TSV. This simple example has a single key, but you can of course extract multiple fields and use "format json" to output newline-delimited JSONs.

The intermediary TSV is at `buffer_path`, and the command `python /path/to/fizzbuzz.py /path/to/buffer_path` is run. This is why in `fizzbuzz.py`, it's reading the file at `sys.argv[-1]`. 
	
If you start Fluentd and run

    :::text
    $ for i in `seq 15`; do echo "{\"fizzbuzz\":$i}" | fluent-cat fizzbuzz; done

Then, after 5 seconds, you get a file named `foobar.out`.

    :::text
	$ cat foobar.out
	1
    2
    fizz
    4
    buzz
    fizz
    7
    8
    fizz
    buzz
    11
    fizz
    13
    14
    fizzbuzz
    
	
## Parameters

### type (required)
The value must be `exec`.

### command (required)
The command (program) to execute. The exec plugin passes the path of a TSV file as the last argument.

### format
The format used to map the incoming events to the program input.

The following formats are supported:

* tsv (default)

When using the tsv format, please also specify the comma-separated `keys` parameter.

    :::text
    keys k1,k2,k3

* json
* msgpack

### tag_key
The name of the key to use as the event tag. This replaces the value in the event record.

### time_key
The name of the key to use as the event time. This replaces the the value in the event record.

### time_format
The format for event time used when the `time_key` parameter is specified. The default is UNIX time (integer).

INCLUDE: _timesliced_buffer_parameters

INCLUDE: _log_level_params

