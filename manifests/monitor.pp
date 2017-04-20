# == Class: monit::monitor
#
# This module configures a service to be monitored by Monit
#
# === Parameters
#
# [*pidfile*]      - Path to the pid file for the service
# [*matching*]     - String to match a process
# [*program*]      - File to execute for check
# [*ensure*]       - If the file should be enforced or not (default: present)
# [*ip_port*]      - Port to check if needed (zero to disable)
# [*socket*]       - Path to socket file if needed (undef to disable)
# [*checks*]       - Array of monit check statements
# [*start_script*] - Scipt used to start the process
# [*stop_script*]  - Scipt used to start the process
#
# === Examples
#
#  monit::monitor { 'monit-watch-monit':
#    pidfile => '/var/run/monit.pid',
#  }
#
# === Authors
#
# Eivind Uggedal <eivind@uggedal.com>
# Jonathan Thurman <jthurman@newrelic.com>
#
# === Copyright
#
# Copyright 2011 Eivind Uggedal <eivind@uggedal.com>
#
define monit::monitor (
  $pidfile       = undef,
  $matching      = undef,
  $program       = undef,
  $ensure        = present,
  $ip_port       = 0,
  $socket        = undef,
  $checks        = [ ],
  $start_script  = "/usr/sbin/invoke-rc.d ${name} start",
  $stop_script   = "/usr/sbin/invoke-rc.d ${name} stop",
  $start_timeout = undef,
  $stop_timeout  = undef,
  $group         = $name,
  $uid           = '',
  $gid           = '',
  $depends       = [],
) {
  include monit::params
  if ($pidfile == undef) and ($matching == undef) and ($program == undef) {
    fail('Only one of pidfile, matching or program must be specified.')
  }
  if ($pidfile != undef) and ($matching != undef) and ($program != undef) {
    fail('Only one of pidfile, matching or program must be specified.')
  }

  # Template uses: $pidfile, $program, $ip_port, $socket, $checks, $start_script, $stop_script, $start_timeout, $stop_timeout, $group, $uid, $gid
  file { "${monit::params::conf_dir}/${name}.conf":
    ensure  => $ensure,
    content => template('monit/process.conf.erb'),
    require => Package[$monit::params::monit_package],
    notify  => [
      Service[$monit::params::monit_service],
      Exec["restart monit service ${name}"],
    ]
  }

  exec { "restart monit service ${name}":
    command     => "/usr/bin/monit restart ${name}",
    refreshonly => true,
    require     => Service[$monit::params::monit_service],
  }
}
