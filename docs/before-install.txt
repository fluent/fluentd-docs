# Before Installing Fluentd

You MUST set up your environment according to the steps below before installing Fluentd. Failing to do so will be the cause of many unnecessary problems.

## Set Up NTP

It's HIGHLY recommended that you set up *ntpd* on the node to prevent invalid timestamps in your logs.

## Increase Max # of File Descriptors

Please increase the maximum number of file descriptors. You can check the current number using the `ulimit -n` command.

    :::term
    $ ulimit -n
    65535

If your console shows `1024`, it is insufficient. Please add following lines to your `/etc/security/limits.conf` file and reboot your machine.

    :::term
    root soft nofile 65536
    root hard nofile 65536
    * soft nofile 65536
    * hard nofile 65536

## Optimize Network Kernel Parameters

For high load environments consisting of many Fluentd instances, please add these parameters to your `/etc/sysctl.conf` file. Please either type `sysctl -w` or reboot your node to have the changes take effect. If your environment doesn't have a problem with TCP_WAIT, then these changes are not needed.

    :::term
    net.ipv4.tcp_tw_recycle = 1
    net.ipv4.tcp_tw_reuse = 1
    net.ipv4.ip_local_port_range = 10240    65535




