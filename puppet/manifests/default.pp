
#
# sites.pp defines defauls for vagrant provisioning
#
#


if $hostname == 'monitor' {

  class { 'emacs':   }
  class { 'ganglia': }
  class { 'splunk':  }
  

}
  
