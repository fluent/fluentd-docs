# Secure Forward Input Plugin

The `in_secure_forward` input plugin accepts messages via **SSL with authentication** (cf. [out_secure_forward](out_secure_forward)).

NOTE: This document doesn't describe all parameters. If you want to know full features, check the Further Reading section.

## Installation

`in_secure_forward` is **not** included in either `td-agent` package or `fluentd` gem. In order to install it, please refer to the <a href="plugin-management">Plugin Management</a> article.

##Example Configurations

This section provides some example configurations for `in_secure_forward`.

###Minimalist Configuration

    <source>
      type secure_forward
      shared_key         secret_string
      self_hostname      server.fqdn.local  # This fqdn is used as CN (Common Name) of certificates
      cert_auto_generate yes                # This parameter MUST be specified
    </source>

###Check username/password from Clients

    <source>
      type secure_forward
      shared_key         secret_string
      self_hostname      server.fqdn.local
      cert_auto_generate yes
      authentication     yes # Deny clients without valid username/password
      <user>
        username tagomoris
        password foobar012
      </user>
      <user>
        username frsyuki
        password yakiniku
      </user>
    </source>

###Deny Unknown Source IP/hosts

    <source>
      type secure_forward
      shared_key         secret_string
      self_hostname      server.fqdn.local
      cert_auto_generate     yes
      allow_anonymous_source no  # Allow to accept from nodes of <client>
      <client>
        host 192.168.10.30
        # network address (ex: 192.168.10.0/24) NOT Supported now
      </client>
      <client>
        host your.host.fqdn.local
        # wildcard (ex: *.host.fqdn.local) NOT Supported now
      </client>
    </source>

You can use the username/password check and client check together:

    <source>
      type secure_forward
      shared_key         secret_string
      self_hostname      server.fqdn.local
      cert_auto_generate     yes
      allow_anonymous_source no  # Allow to accept from nodes of <client>
      authentication         yes # Deny clients without valid username/password
      <user>
        username tagomoris
        password foobar012
      </user>
      <user>
        username frsyuki
        password sukiyaki
      </user>
      <user>
        username repeatedly
        password sushi
      </user
      <client>
        host 192.168.10.30      # allow all users to connect from 192.168.10.30
      </client>
      <client>
        host  192.168.10.31
        users tagomoris,frsyuki # deny repeatedly from 192.168.10.31
      </client>
      <client>
        host 192.168.10.32
        shared_key less_secret_string # limited shared_key for 192.168.10.32
        users      repeatedly         # and repeatedly only
      </client>
    </source>

###Secure Sender-Receiver Setup
Please refer to the **Secure Sender-Receiver Setup** [sample documentation](out_secure_forward#Secure-Sender-Receiver-Setup).

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

####allow_keepalive (bool)
Accept keepalive connection. The default value is `true`.

####allow_anonymous_source (bool)
Accept connections from unknown hosts.

####authentication (bool)
Require password authentication. The default value is `false`.

####cert_auto_generate (bool)
Auto-generate the CA (see the `generate_*` parameters below). The default value is `false`.

If `cert_auto_generate` is false, `cert_file_path` must be set.

####generate_private_key_length (integer)
The byte length of the auto-generated private key. The default value is 2048.

####generate_cert_country (string)
The country of the auto-generated certificate. The default value is "US".

####generate_cert_state (string)
The state of the auto-generated certificate. The default value is "CA".

####generate_cert_locality (string)
The locality of the auto-generated certificate. The default value is "Mountain View".

####generate_cert_common_name (string)
The common name of the auto-generated certificate. The default value is the value of `self_hostname`.

####cert_file_path (string)
The path to the cert file. If this is not set, `cert_auto_generate` must be set to `true`.

####private_key_file (string)
The path to the private key file used with the cert file located at `cert_file_path`.

####private_key_passphrase (string)
The optional passphrase for the private key file found in `private_key_file`.

####read_length (size)
The number of bytes read per nonblocking read. The default value is 8MB=8*1024*1024 bytes.

####read_interval_msec (integer)
The interval between the non-blocking reads, in milliseconds. The default value is 50.

####socket_interval_msec (integer)
The interval between SSL reconnects in milliseconds. The default value is 200.


INCLUDE: _buffer_parameters


INCLUDE: _log_level_params


## Further Reading
- [fluent-plugin-secure-forward repository](https://github.com/tagomoris/fluent-plugin-secure-forward)
