
#Collecting Log Data from Windows

In this article, we explain how to get started with collecting data from Windows machines (This setup has been tested on a 64-bit Windows 8 machine).

As of v10, Fluentd does NOT support Windows. However, there are times when you must collect data streams from Windows machines. For example:

1. **Tailing log files on Windows**: collect and analyze log data from a Windows application.
2. **Collecting Windows Event Logs**: collect event logs from your Windows servers for system analysis, compliance checking, etc.

**If you're not familiar with Fluentd**, please learn more about Fluentd first.

<center>
<div class="btn-look" style="width: 300px;">
<a href="http://docs.fluentd.org/articles/architecture">What is Fluentd?</a>
</div>
</center>
<br/>
<br/>

##Prerequisites

1. [nxlog](http://nxlog.org), an open source log management tool that runs on Windows.
2. A Linux server (we assume Ubuntu 12 for this article)

##Setup

###Set up a Linux server with rsyslogd and Fluentd

1. Get hold of a Linux server. In this example, we assume it is Ubuntu.
2. **Make sure it has ports open for TCP. In the following example, we assume port 5140 is open.**
3. [Install td-agent](http://docs.fluentd.org/articles/install-by-deb). (See [here](/categories/installation) for various ways to install Fluentd/Treasure Agent)
4. Edit td-agent's configuration file located at `/etc/td-agent/td-agent.conf` and add the following lines

        <source>
          type tcp
          format none
          port 5140
          tag windowslog
        </source>    
        <match windowslog>
          type stdout
        </match>

        The above code listens to port 5140 (UDP) and outputs the data to stdout (which is piped to `/var/log/td-agent/td-agent.log`)    
5. Start td-agent by running `sudo service td-agent start`

###Set up nxlog on Windows

1. Follow [this link](http://nxlog.org/download) and download a copy of nxlog onto the Windows machine you want to collect log data from. Open the downloaded installer and follow the instructions. By default, it should be installed in `C:\Program Files (x86)\nxlog`
2. Create an nxlog config file as follows and save it as `nxlog.conf`:

        #define ROOT C:\Program Files\nxlog
        define ROOT C:\Program Files (x86)\nxlog

        Moduledir %ROOT%\modules
        CacheDir %ROOT%\data
        Pidfile %ROOT%\data\nxlog.pid
        SpoolDir %ROOT%\data
        LogFile %ROOT%\data\nxlog.log

        <Input in>
          Module im_file
          File 'C:\Users\SomeUser\Desktop\nxlog_test.log' #Put the file to be tailed here.
          SavePos TRUE
          InputType LineBased
        </Input>

        <Output out>
          Module om_tcp
          Host localhost
          Port 9200
        </Output> 

        <Route r>
          Path in => out
        </Route>
    
    This configuration will send each line of the log file (see the File parameter inside &lt;Input in&gt...&lt;/Input&gt;) as a syslog message to a remote Fluentd/Treasure Agent instance.

###Test
1. Go to nxlog's directory (in Powershell or Command Prompt) and run the following command:
        
        \nxlog.exe -f -c  <path to nxlog.conf>
    
    The "-f" option runs nxlog in the foreground (this is for testing). If this is for production, you would want to turn it into a Windows Service.
2. Once nxlog is running, add a new line "Windows is awesome" into the tailed file like this:
        
        echo Windows is awesome >> 'C:\Users\SomeUser\Desktop\nxlog_test.log'

3. Now, go to the Linux server and run

        $ sudo tail -f /var/log/td-agent/td-agent.log
        ...
        ...
        ...
        2014-12-20 02:19:36 +0000 windowslog: {"message":"Windows is awesome \r"}
4. You successfully sent data from a Windows machine to a remote Fluentd instance running on Linux.

###Parsing JSON Logs

If you are sending JSON logs on Windows to Fluentd, Fluentd can parse them as they come in. To do, simply change Fluentd's configuration as follows. Note the change from `format none` to `format json`. (See [this article](parser-plugin-overview) for more details about the parser plugins)

    :::text
    <source>
      type tcp
      format json
      port 5140
      tag windowslog
    </source>    
    <match windowslog>
      type stdout
    </match>

Then, if you add a new line to the file on your windows machine like this:
    
    :::text
    echo {"name":"Sadayuki", "age":27} >> 'C:\Users\SomeUser\Desktop\nxlog_test.log'

On the Linux machine running Fluentd, you see the following line:

    :::text
    2014-12-20 02:22:44 +0000 windowslog: {"name":"Sadayuki","age":27}



###Next Step

This example showed that we can collect data from a Windows machine and send it to a remote Fluentd instance. However, the data is not terribly useful because each line of data is placed into the "message" field as unstructured text. For production purposes, you would probably want to write a plugin/extend the syslog plugin so that you can parse the "message" field in the event.

## Learn More

* [Fluentd Architecture](architecture)
* [Fluentd Get Started](quickstart)
