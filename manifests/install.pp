# == Class opendaylight::install
#
# Manages the installation of OpenDaylight.
#
# There are two install methods: RPM-based and deb-based. The resulting
# system state should be functionally equivalent.
#
class opendaylight::install {
  if $::osfamily == 'RedHat' {
    # Add OpenDaylight's Yum repository
    yumrepo { $opendaylight::rpm_repo:
      # 'ensure' isn't supported with Puppet <3.5
      # Seems to default to present, but docs don't say
      # https://docs.puppetlabs.com/references/3.4.0/type.html#yumrepo
      # https://docs.puppetlabs.com/references/3.5.0/type.html#yumrepo
      baseurl  => "http://cbs.centos.org/repos/nfv7-${opendaylight::rpm_repo}/\$basearch/os/",
      descr    => 'OpenDaylight SDN Controller',
      enabled  => 1,
      # NB: RPM signing is an active TODO, but is not done. We will enable
      #     this gpgcheck once the RPM supports it.
      gpgcheck => 0,
      before   => Package['opendaylight'],
    }

    # Install the OpenDaylight RPM
    package { 'opendaylight':
      ensure  => present,
      require => Yumrepo[$opendaylight::rpm_repo],
    }
    ->
    # Configure the systemd file with Java options
    file_line { 'java_options_systemd':
      ensure => present,
      path   => '/usr/lib/systemd/system/opendaylight.service',
      line   => "Environment=_JAVA_OPTIONS=\'${opendaylight::java_opts}\'",
      match  => '^Environment.*',
      after  => 'ExecStart=/opt/opendaylight/bin/start',
    }
    ~>
    exec {'reload_systemd_units':
      command     => 'systemctl daemon-reload',
      path        => '/bin',
      refreshonly => true,
    }
  }

  elsif $::osfamily == 'Debian'{

    include apt

    # Add ODL ppa repository
    apt::ppa{ $opendaylight::deb_repo: }

    # Install Opendaylight .deb pkg
    package { 'opendaylight':
      ensure  => present,
      require => Apt::Ppa[$opendaylight::deb_repo],
    }

    Apt::Ppa[$opendaylight::deb_repo] -> Package['opendaylight']
  }
  else {
    fail("Unknown operating system method: ${::osfamily}")
  }
}
