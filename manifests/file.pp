define monit::file(
  String $path,
  Enum['absent', 'present'] $ensure = 'present',
  Array[String] $actions            = [],
) {
  file { "${monit::params::conf_dir}/${name}.conf":
    ensure  => $ensure,
    content => template('monit/file.conf.erb'),
    notify  => Service[$monit::params::monit_service],
    require => Package[$monit::params::monit_package],
  }
}
