# == Class opendaylight::params
#
# This class is meant to be called from opendaylight.
# It sets variables according to platform.
#
class opendaylight::params {
  if $::osfamily == 'RedHat' {
    $package_name = 'opendaylight'
    $service_name = 'opendaylight'
  }
  else {
    fail("Unsupported OS family: ${::osfamily}")
  }
}
