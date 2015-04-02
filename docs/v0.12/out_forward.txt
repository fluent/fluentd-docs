# forward Output Plugin

The `out_forward` Buffered Output plugin forwards events to other fluentd nodes. This plugin supports load-balancing and automatic fail-over (a.k.a. active-active backup). For replication, please use the [out_copy](out_copy) plugin.

The `out_forward` plugin detects server faults using a “φ accrual failure detector” algorithm. You can customize the parameters of the algorithm. When a server fault recovers, the plugin makes the server available automatically after a few seconds.

The `out_forward` plugin supports at-most-once and at-least-once semantics. The default is at-most-once.

NOTE: Do <b>NOT</b> use this plugin for inter-DC or public internet data transfer without secure connections. All the data is not encrypted, and this plugin is not designed for high-latency network environment. If you require a secure connection between nodes, please consider using <a href="in_secure_forward">in_secure_forward</a>.

## Example Configuration

`out_forward` is included in Fluentd's core. No additional installation process is required.

    :::text
    <match pattern>
      type forward
      send_timeout 60s
      recover_wait 10s
      heartbeat_interval 1s
      phi_threshold 16
      hard_timeout 60s
      
      <server>
        name myserver1
        host 192.168.1.3
        port 24224
        weight 60
      </server>
      <server>
        name myserver2
        host 192.168.1.4
        port 24224
        weight 60
      </server>
      ...
      
      <secondary>
        type file
        path /var/log/fluent/forward-failed
      </secondary>
    </match>

NOTE: Please see the <a href="config-file">Config File</a> article for the basic structure and syntax of the configuration file.

## Parameters

### type (required)
The value must be `forward`.

### &lt;server&gt; (at least one is required)
The destination servers. Each server must have following information.

* *name*: The name of the server. This parameter is used in error messages.
* *host* (required): The IP address or host name of the server.
* *port*: The port number of the host. The default is 24224. Note that both TCP packets (event stream) and UDP packets (heartbeat message) are sent to this port.
* *weight*: The load balancing weight. If the weight of one server is 20 and the weight of the other server is 30, events are sent in a 2:3 raito. The default weight is 60.

### require_ack_response
Change the protocol to at-least-once. The plugin waits the ack from destination's in_forward plugin.

### ack_response_timeout
This option is used when `require_ack_response` is `true`. The default is 190. This default value is based on popular tcp_syn_retries.

If set `0`, this plugin doesn't wait the ack response.

### &lt;secondary&gt; (optional)
The backup destination that is used when all servers are unavailable.

### send_timeout
The timeout time when sending event logs. The default is 60 seconds.

### recover_wait
The wait time before accepting a server fault recovery. The default is 10 seconds.

### heartbeat_type
The transport protocol to use for heartbeats. The default is "udp", but you can select "tcp" as well.

### heartbeat_interval
The interval of the heartbeat packer. The default is 1 second.

### phi_failure_detector
Use the "Phi accrual failure detector" to detect server failure. The default value is `true`.

### phi_threshold
The threshold parameter used to detect server faults. The default value is 16.

### hard_timeout
The hard timeout used to detect server failure. The default value is equal to the send_timeout parameter.

### standby
Marks a node as the standby node for an Active-Standby model between Fluentd nodes. When an active node goes down, the standby node is promoted to an active node. The standby node is not used by the `out_forward` plugin until then.

    :::text
    <match pattern>
      type forward
      ...
      
      <server>
        name myserver1
        host 192.168.1.3
        weight 60
      </server>
      <server>  # forward doesn't use myserver2 until myserver1 goes down
        name myserver2
        host 192.168.1.4
        weight 60
        standby
      </server>
      ...
    </match>


INCLUDE: _buffer_parameters

INCLUDE: _log_level_params


## Troubleshooting

### "no nodes are available"
Please make sure that you can communicate with port 24224 using **not only TCP, but also UDP**. These commands will be useful for checking the network configuration.

    :::term
    $ telnet host 24224
    $ nmap -p 24224 -sU host

Please note that there is one [known issue](http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2019944) where VMware will occasionally lose small UDP packets used for heartbeat.
