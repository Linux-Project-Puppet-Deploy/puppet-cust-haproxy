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
    enable           => true,
    global_options   => {
      'log'     => "${::ipaddress} local0",
      'chroot'  => '/var/lib/haproxy',
      'pidfile' => '/var/run/haproxy.pid',
      'maxconn' => '4000',
      'user'    => 'haproxy',
      'group'   => 'haproxy',
      'daemon'  => '',
      'stats'   => 'socket /var/lib/haproxy/stats',
    },
    defaults_options => {
      'log'     => 'global',
      'stats'   => 'enable',
      'option'  => 'redispatch',
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
  haproxy::listen { 'stats':
    ipaddress => '*',
    ports     => '9090',
    options   => {
      'mode'  => 'http',
      'stats' => [
        'uri /',
        'auth puppet:puppet'
      ],
    },
  }
}
