# Authors
# -------
#
# Tony LAUNAY <tony.launay@ynov.com>
#
# Copyright
# ---------
#
# Copyright 2017 Tony LAUNAY.
#
class cust_haproxy {
  class { 'haproxy':
    global_options   => {
      'chroot'  => '/var/lib/haproxy',
      'pidfile' => '/var/run/haproxy.pid',
      'maxconn' => '4000',
      'user'    => 'haproxy',
      'group'   => 'haproxy',
      'daemon'  => '',
    },
    defaults_options => {
      'log'     => 'global',
      'option'  => [
        'http-server-close',
        'redispatch',
        'dontlognull',
      ],
      'retries' => '3',
      'timeout' => [
        'http-request 10s',
        'queue 1m',
        'connect 10s',
        'client 1m',
        'server 1m',
        'check 10s',
      ],
      'maxconn' => '8000',
    },
  }

  haproxy::listen { 'statistics':
    ipaddress => '*',
    ports => '8080',
    mode => 'http',
    options   => {
      'stats' => [
        'enable',
        'refresh 30s',
        'uri /',
        'show-node',
        'show-legends',
        'hide-version',
        'auth puppet:puppet',
      ],
    }
  }

  haproxy::frontend { 'HTTP-FRONT':
    ports => '80',
    mode => 'tcp',
    options => {
      'compression' => [
        'algo gzip',
        'type text/html text/plain text/javascript application/javascript application/xml text/css',
      ],
      'acl' => 'webhosting hdr_end(host) -i -f /etc/haproxy/url_webhosting',
      'use_backend' => 'WEBHOSTING if webhosting',      
    }
  }

  haproxy::backend { 'WEBHOSTING':
    options => {
      'balance' => 'roundrobin',
      'cookie' => 'JSESSIONID prefix',
      'compression' => [
        'algo gzip',
        'type text/html text/plain text/javascript application/javascript application/xml text/css'
      ],
      'server' => [
        'SRV-WEB01 10.37.129.6:80 cookie A check',
        'SRV-WEB02 10.37.129.7:80 cookie A check',
      ]
    },
  }

  file { '/etc/haproxy/url_webhosting':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/cust_haproxy/url_webhosting',
  }         
}
