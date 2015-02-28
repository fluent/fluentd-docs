# Secure Forward Output Plugin

The `out_secure_forward` output plugin sends messages via **SSL with authentication** (cf. [in_secure_forward](in_secure_forward)).

NOTE: This document doesn't describe all parameters. If you want to know full features, check the Further Reading section.

## Installation

`out_secure_forward` is **not** included in either `td-agent` package or `fluentd` gem. In order to install it, please refer to the <a href="plugin-management">Plugin Management</a> article.

##Example Configurations

This section provides some example configurations for `out_secure_forward`.

###Minimalist Configuration

    <match secret.data.**>
      type secure_forward
      shared_key secret_string
      self_hostname client.fqdn.local
      <server>
        host server.fqdn.local  # or IP
        # port 24284
      </server>
    </match>

NOTE: Without hostname ACL (not yet implemented), `self_hostname` is not checked in any state. The `${hostname}` placeholder is available for such cases.

    <match secret.data.**>
      type secure_forward
      shared_key secret_string
      self_hostname ${hostname}
      <server>
        host server.fqdn.local  # or IP
        # port 24284
      </server>
    </match>

###Multiple Forward Destinations over SSL

When two or more `<server>...</server>` clauses are specified, `out_secure_forward` uses these server nodes in a round-robin order. The servers with `standby yes` are NOT selected until all non-standby servers go down.

NOTE: If a server requires username & password, set `username` and `password` in the `<server>` section:

    <match secret.data.**>
      type secure_forward
      shared_key secret_string
      self_hostname client.fqdn.local
      <server>
        host first.fqdn.local
        username repeatedly
        password sushi
      </server>
      <server>
        host second.fqdn.local
        username sasatatsu
        password karaage
      </server>
      <server>
        host standby.fqdn.local
        username kzk
        password hawaii
        standby  yes
      </server>
    </match>

Use the `keepalive` parameter to specify keepalive timeouts. For example, the configuration below disconnects and re-connects its SSL connection every hour. By default, `keepalive` is set to 0 and the connection does NOT get disconnected unless there is a connection issue (This feature is for DNS name updates and refreshing SSL common keys).

    <match secret.data.**>
      type secure_forward
      shared_key secret_string
      self_hostname client.fqdn.local
      keepalive 3600
      <server>
        host server.fqdn.local  # or IP
        # port 24284
      </server>
    </match>


###Secure Sender-Receiver Setup

Example to send and receive several different kinds of logs (format is set to none for simplicity here).

####Sender 


    # td-agent secured client (sender)
    
    <source>
        type tail
        path /appbase/logs/apache/apache_access_log
        pos_file /var/log/td-agent/tmp/apache.access.pos
        tag apache.access
        format none
    </source>
    
    <source>
        type tail
        path /appbase/logs/apache/apache_error_log
        pos_file /var/log/td-agent/tmp/apache.error.pos
        tag apache.error
        format none
    </source>
    
    <source>
        type tail
        path /appbase/logs/webapp/elastic_search.log
        pos_file /var/log/td-agent/tmp/elastic.search.pos
        tag elastic.search
        format none
    </source>
    
    <source>
        type tail
        path /appbase/logs/webapp/elastic_search_poller.log
        pos_file /var/log/td-agent/tmp/elastic.search.poller.pos
        tag elastic.poller
        format none
    </source>
    
    <source>
        type tail
        path /appbase/logs/webapp/ldap.log
        pos_file /var/log/td-agent/tmp/ldap.log.pos
        tag ldap.log
        format none
    </source>
    
    
    
    #-- Application Logs
    
    <match apache.*>
        type copy
        <store>
           type secure_forward
           shared_key Supers3cr3t
           allow_self_signed_certificate true
           self_hostname frontend01.dev.company.net
            <server>
              host logserver01.prd.company.net
              port 2514
            </server>
           <server>
             host logserver02.prd.company.net
             port 2514
           </server>
        </store>
    </match>

    <match elastic.*>
        type copy
        <store>
           type secure_forward
           shared_key Supers3cr3t
           allow_self_signed_certificate true
           self_hostname frontend01.dev.company.net
            <server>
              host logserver01.prd.company.net
              port 2514
            </server>
           <server>
             host logserver02.prd.company.net
             port 2514
           </server>
        </store>
    </match>
    
    <match ldap.*>
        type copy
        <store>
           type secure_forward
           shared_key Supers3cr3t
           allow_self_signed_certificate true
           self_hostname frontend01.dev.company.net
            <server>
              host logserver01.prd.company.net
              port 2514
            </server>
           <server>
             host logserver02.prd.company.net
             port 2514
           </server>
        </store>
    </match>
    
    #-- NOTE for troubleshooting any actions afer "type copy",
    #-- and receive more output in td-agent.log, add:
    #--       <store>
    #--           type stdout
    #--       </store>
    
    
    #-- Fluent Internal Logs
    
    <match **>
       type secure_forward
       shared_key Supers3cr3t
       self_hostname frontend01.dev.company.net
       flush_interval 8s
       <server>
         host logserver01.prd.company.net
         port 2514
       </server>
       <server>
         host logserver02.prd.company.net
         port 2514
       </server>
    </match>


####Receiver

    # td-agent secured receiver (server)
    
    <source>
      type secure_forward
      shared_key         Supers3cr3t
      self_hostname      logserver01.prd.company.net
      cert_auto_generate yes
      port 2514
    </source>
    
    
    #-- Application Logs
    
    <match *.access>
        type file
        append true
        path /appbase/logs/received/access
        time_slice_format %Y%m%d
        time_slice_wait 5m
        time_format %Y%m%dT%H:%M:%S%z
    </match>
    
    <match *.error>
        type file
        append true
        path /appbase/logs/received/error
        time_slice_format %Y%m%d
        time_slice_wait 5m
        time_format %Y%m%dT%H:%M:%S%z
    </match>
    
    <match elastic.search>
        type file
        append true
        path /appbase/logs/received/elastic_search
        time_slice_format %Y%m%d
        time_slice_wait 5m
        time_format %Y%m%dT%H:%M:%S%z
    </match>
    
    <match elastic.poller>
        type file
        append true
        path /appbase/logs/received/elastic_search_poller
        time_slice_format %Y%m%d
        time_slice_wait 5m
        time_format %Y%m%dT%H:%M:%S%z
    </match>
    
    <match ldap.*>
        type file
        append true
        path /appbase/logs/received/ldap
        time_slice_format %Y%m%d
        time_slice_wait 5m
        time_format %Y%m%dT%H:%M:%S%z
    </match>
    
    
    #-- Fluent Internal Logs

    <match fluent.info>
        type file
        append true
        path /appbase/logs/received/fluent-info
    </match>
    
    <match fluent.warn>
        type file
        append true
        path /appbase/logs/received/fluent-warn
    </match>


##Parameters

####type
This parameter is required. Its value must be `secure_forward`.

####port (integer)
The default value is 24284.

####bind (sring)
The default value is 0.0.0.0.

####self_hostname (string)
Default value of the auto-generated certificate common name (CN).

####shared_key (string)
Optional shared key.

####keepalive (time)
The duration for keepalive. If this parameter is not specified, keepalive is disabled.

####send_timeout (time)
The send timeout value for sockets. The default value is 60 seconds.

####allow_self_signed_certificate (bool)
Enables self-signed CA. The default is `true`.

####ca_file_path (string)
The path to the certificate file.

####reconnect_interval (time)
The interval between SSL reconnects. The default value is 5 seconds.

####read_length (integer)
The number of bytes read per nonblocking read. The default value is 8MB=8*1024*1024 bytes.

####read_interval_msec (integer)
The interval between the non-blocking reads, in milliseconds. The default value is 50.

####socket_interval_msec (integer)
The interval between SSL reconnects in milliseconds. The default value is 200.


INCLUDE: _buffer_parameters


INCLUDE: _log_level_params


## Further Reading
- [fluent-plugin-secure-forward repository](https://github.com/tagomoris/fluent-plugin-secure-forward)
