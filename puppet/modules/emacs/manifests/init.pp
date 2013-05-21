#
# Installs the passed in version of emacs. Handles the
# case where it needs to install from source vs package
# management.
#
class emacs($verison = '24.2') {
  package {  "emacs":
    ensure => installed,
  }
}
