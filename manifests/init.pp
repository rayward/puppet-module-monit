# == Class: monit
#
# This module controls Monit
#
# === Parameters
#
# [*ensure*]    - If you want the service running or not
# [*admin*]     - Admin email address
# [*interval*]  - How frequently the check runs
# [*delay*]     - How long to wait before actually performing any action
# [*logfile*]   - What file for monit use for logging
# [*mailserver] - Which mailserver to use
# === Examples
#
#  class { 'monit':
#    admin    => 'me@mydomain.local',
#    interval => 30,
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
class monit (
  $ensure     = present,
  $admin      = undef,
  $interval   = 60,
  $delay      = undef,
  $logfile    = $monit::params::logfile,
  $mailserver = 'localhost',
) inherits monit::params {

  if ($delay == undef) {
    $use_delay = $interval * 2
  }
  else {
    $use_delay = $delay
  }

  $conf_include = "${monit::params::conf_dir}/*"

  if ($ensure == 'present') {
    $run_service = true
    $service_state = 'running'
  } else {
    $run_service = false
    $service_state = 'stopped'
  }

  package { $monit::params::monit_package:
    ensure => $ensure,
  }

  # Template uses: $admin, $conf_include, $interval, $logfile
  file { $monit::params::conf_file:
    ensure  => $ensure,
    content => template('monit/monitrc.erb'),
    mode    => '0600',
    require => Package[$monit::params::monit_package],
    notify  => Service[$monit::params::monit_service],
  }

  file { $monit::params::conf_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[$monit::params::monit_package],
    notify  => Service[$monit::params::monit_service],
    purge   => true,
    force   => true,
    recurse => true,
  }

  # Not all platforms need this
  if ($monit::params::default_conf) {
    if ($monit::params::default_conf_tpl) {
      file { $monit::params::default_conf:
        ensure  => $ensure,
        content => template("monit/${monit::params::default_conf_tpl}"),
        require => Package[$monit::params::monit_package],
      }
    } else {
      fail('You need to provide config template')
    }
  }

  # Template uses: $logfile
  file { $monit::params::logrotate_script:
    ensure  => $ensure,
    content => template("monit/${monit::params::logrotate_source}"),
    require => Package[$monit::params::monit_package],
  }

  service { $monit::params::monit_service:
    ensure     => $service_state,
    enable     => $run_service,
    hasrestart => true,
    restart    => '/etc/init.d/monit reload && sleep 3',
    hasstatus  => $monit::params::service_has_status,
    subscribe  => File[$monit::params::conf_file],
    require    => [
      File[$monit::params::conf_file],
      File[$monit::params::logrotate_script]
    ],
  }
  file {'/etc/bash_completion.d/monit':
    ensure => present,
    source => "puppet:///modules/${module_name}/monit-bash_completion",
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }
}
