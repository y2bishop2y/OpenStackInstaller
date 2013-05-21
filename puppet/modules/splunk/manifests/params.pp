

class splunk::params {

  # valid values are server, forwarder
  $deploy     = $::splunk_deploy
  $splunk_ver =  '5.0.2'
  $installer  = $deploy ? {

    'server' => $::architecture ? {

      'i386'   => $::operatingsystem ? {
        /(?i)(centos|redhat)/ => "splunk-${splunk_ver}.i386.rpm",
        'debian'              => "splunk-${splunk_ver}-linux-2.6-intel.deb",
        
      },
      'x86_64' => $::operatingsystem ? {
        /(?i)(centos|redhat)/ => "splunk-${splunk_ver}-linux-2.6-x86_64.rpm",
        'debian'              => "splunk-${splunk_ver}-linux-2.6-amd64.deb",
      },
    },

    'forwarder' => $::architecture ? {
      'i386'   => $::operatingsystem ? {
        /(?i)(centos|redhat)/  => "splunkforwarder-${splunk_ver}.i386.rpm",
        /(?i)(debian|ubuntu)/  => "splunkforwarder-${splunk_ver}-linux-2.6-intel.deb",
      },
      'x86_64' => $::opeartingsystem ? {
        /(?i)(centos|redhat)/  => "splunkforwarder-${splunk_ver}-linux-2.6-x86_64.rpm",
        /(?i)(debian|ubuntu)/  => "splunkforwarder-${splunk_ver}-linux-2.6-amd64.deb",
      },
    },
    
  }

  #-- Not validated, but should be hostname or IP
  $logging_server    = $::splunk_logging_server
  $syslogging_port   = $::splunk_syslog_port
  $logging_port      = $::splunk_forwarder_port
  $splunkd_port      = '8089'
  $admin_port        = '8080'
  $linux_stage_dir   = "/usr/local/installers"
  $splunk_admin      = "admin"
  $splunk_admin_pass = "changeme"

  
}
