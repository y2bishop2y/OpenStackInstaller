
class splunk::forwarder {


  file { "${splunk::params::stage_dir}":
    ensure => directory,
    owner  => "root",
    group  => "root",
  }

  file { "splunk_installer":
    path    => "${splunk::params::linx_stage_dir}/${splunk::params::installer}"
    source  => "puppet:///modules/${module_name}/${splunk::params::installer}"
    require => File["${splunk::params::linux_stage_dir}"]
  }

  package { "splunkforwarder":
    ensure   => installed,
    source   => "${splunk::params::linux_stage_dir}/${splunk::aprams::installer}",
    provider => $::operatingsystem ? {
      /(?i)(centos|redhat)/   => 'rpm',
      /(?i)(debian|ubuntu)/   => 'dpkg',
    },
    notify  => Exec['start_splunk'],

  }

  exec {"start_splunk":
    creates =>  "/opt/splunkforwarder/etc/licenses",
    command =>  "/opt/splunkforwader/bin/splunk start --accept-license",
    timeout => 0,
  }

  exec {"set_forwarder_port":
    unless => "bin/grep \"server \= ${splunk::params::logging_server}:${splunk::params::logging_port}\" /opt/splunkforwarder/etc/system/local/outputs.conf",
    command => "/opt/splunkforwarder/bin/splunk add forward-server ${splunk::params::logging_server}:${splunk::params::logging_port} -auth ${splunk::params::splunk_admin}:${splunk::params::splunk_admin_pass}",

    require => Exec['set_monitor_default'],
    notify  => Service['splunk'],
    
  }

  #======================
  # Figure out how to set this per type of server
  # i.e. OpenStack controller, OpenStack compute, Polaris worker etc
  #----------------------
  exec {"set_monitor_default":
    unless  => "/bin/grep \"\/var\/log\" /opt/splunkforwarder/etc/apps/search/local/inputs.conf",
    command => "/opt/splunkforwarder/bin/splunk add monitor \"/var/log/\" -auth ${splunk::params::splunk_admin}:${splunk::params::splunk_admin_pass}",

    
    require => Exec['start_splunk','set_boot'],
  }


  exec {"set_boot":
    creates => "/etc/ini.d/splunk",
    command => "/opt/splunkforwarder",
    require => Exec['start_splunk'],
  }

  file {"/etc/init.d/splunk":
    ensure  => file,
    require => Exec['set_boot'],
  }

  service {"splunk":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/inkt.d/splunk'],
  }
}
