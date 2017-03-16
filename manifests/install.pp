# == Class opendaylight::install
#
# Manages the installation of OpenDaylight.
#
# There are two install methods: RPM-based and deb-based. The resulting
# system state should be functionally equivalent.
#
class opendaylight::install {

  if $::opendaylight::manage_repositories {
    require ::opendaylight::repos
  }

  package { 'opendaylight':
    ensure  => present,
  }

  if $::osfamily == 'RedHat' {
    # Configure the systemd file with Java options
    file_line { 'java_options_systemd':
      ensure  => present,
      path    => '/usr/lib/systemd/system/opendaylight.service',
      line    => "Environment=_JAVA_OPTIONS=\'${::opendaylight::java_opts}\'",
      match   => '^Environment.*',
      after   => 'ExecStart=/opt/opendaylight/bin/start',
      require => Package['opendaylight'],
    }
    ->
    exec {'reload_systemd_units':
      command => 'systemctl daemon-reload',
      path    => '/bin'
    }
  }
}
