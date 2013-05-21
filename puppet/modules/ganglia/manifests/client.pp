# Class: ganglia::client
#
# This class installs the ganglia client
# 
# Parameters:
#    $cluster
#
# 
class ganglia::client (
  $ensure   = 'installed',
  $cluster  = 'unspecified',
  $multicast_address = '172.0.0.0',
  $owner    = 'unspecified',
  $send_metadata_interval = 0,
  $udp_port            = '8649',
  $unicast_listen_port = '8649',
  $unicast_targets     = [],
  $network_mode        = 'multicast',
  $user                = 'ganglia',
  ) {

  case $::osfamily {
    'Debian': {
      $ganglia_client_pkg     = 'ganglia-monitor',
      $ganglia_client_service = 'ganglia-monitor',
      $ganglia_lib_dir        = '/usr/lib/ganglia'
      Service[$ganglia_client_service] {
        hasstatus => false,
        status    => "ps -ef | grep gmod | grep ${user} | grep -qv grep"
      }
    }

    'Redhat': {
      # requires eps repo
      $ganglia_client_pkg     = 'ganglia-gmond',
      $ganglia_client_service = 'gmond',
      $ganglia_lib_dir        = $::architecture ? {
        /(amd64|x86_64)/  => '/usr/lib64/ganglia',
        default           => '/usr/lib/ganglia',
      }
    }
    default: { fail('unknown ganglia monitor package for this OS') }
  }

  package {$ganglia_client_pkg:
    ensure => $ensure,
    alias  => 'ganglia_client',
  }

  service {$ganglia_client_service:
    ensure  => 'running',
    alias   => 'ganglia_client',
    require => Package[$ganglia_client_pkg];
  }

  file {'/etc/ganglia/gmond.conf':
    ensure    => present,
    require   => Package['ganglia_client'],
    content   => template('ganglia/gmond.conf'),
    notify    => Service[$ganglia_client_serivce];

  }
    
}
  

