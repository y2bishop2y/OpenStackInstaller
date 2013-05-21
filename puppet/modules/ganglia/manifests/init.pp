# Class:ganglia
#
# This class includes common components for ganglia installations
#
# Parameters:
#
# Actions:
#
# Sample usage:
#    include ganglia
#  
class ganglia {
  package {'rrdtool':
    ensure => 'installed',
  }
}
