# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  #============================
  # NOVA Controller Node
  #----------------------------
  config.vm.define :controller do |controller_config|

    # Every Vagrant virtual environment requires a box to build off of.
    controller_config.vm.box      = "precise64"

    # Puppet wants a hostname that is FQDN
    controller_config.vm.hostname = "controller.local"

    # The url from where the 'config.vm.box' box will be fetched if it
    # doesn't already exist on the user's system.
    controller_config.vm.box_url = "http://files.vagrantup.com/precise64.box"

    # Boot with a GUI so you can see the screen. (Default is headless)
    # config.vm.boot_mode = :gui

    # Assign this VM to a host-only network IP, allowing you to access it
    # via the IP. Host-only networks can talk to the host machine as well as
    # any other machines on the same network, but cannot be accessed (through this
    # network interface) by any external networks.
    controller_config.vm.network :private_network, ip: "100.10.10.1", :netmask => "255.255.0.0"
    controller_config.vm.network :private_network, ip: "100.20.20.1", :netmask => "255.255.0.0"

    # Customise the VM virtual hardware

    controller_config.vm.provider "virtualbox" do |v|
      # v.gui = true
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--cpus", 1]
      v.customize ["createhd", "--filename", "controller-cinder.vdi", "--size", 20480]
      v.customize ["storageattach", :id, "--storagectl", "SATA Controller","--port", 1, "--device", 0, "--type", "hdd", "--medium", "controller-cinder.vdi"] 
    end
  
    # Execute the installation scripts (via SSH)
    # controller_config.vm.provision :shell, :path => "vagrant-ovs-bootstrap.sh"
    # controller_config.vm.provision :shell, :path => "vagrant-controller-bootstrap.sh"

    # controller_config.vm.provision :shell, :inline => "cd /vagrant && ./vagrant-ovs-bootstrap.sh"
    # controller_config.vm.provision :shell, :inline => "cd /vagrant && ./vagrant-controller-bootstrap.sh"

  end

  #============================
  # NOVA Compute Node
  #----------------------------
  config.vm.define :compute do |compute_config|

    # Every Vagrant virtual environment requires a box to build off of.
    compute_config.vm.box       = "precise64"

    # Puppet wants a hostname that is FQDN
    compute_config.vm.hostname = "compute.local"

    # The url from where the 'config.vm.box' box will be fetched if it
    # doesn't already exist on the user's system.
    compute_config.vm.box_url = "http://files.vagrantup.com/precise64.box"

    # compute_config.vm.network :private_network, ip: "172.16.0.205", :netmask => "255.255.0.0"
    compute_config.vm.network :private_network, ip: "100.10.10.2",   :netmask => "255.255.0.0"
    compute_config.vm.network :private_network, ip: "100.20.20.2"

    # Customise the VM virtual hardware
    compute_config.vm.provider "virtualbox" do |v|
      # v.gui = true
      v.customize ["modifyvm", :id, "--memory", 8192]
      v.customize ["modifyvm", :id, "--cpus", 2]
    end

    # Execute the installation scripts (via SSH)
    # compute_config.vm.provision :shell, :inline => "cd /vagrant && ./vagrant-compute-bootstrap.sh"
   end

  #============================
  # Network Node: Running quantum
  # TODO:
  #----------------------------
  config.vm.define :network do |network_config|

    # Every Vagrant virtual environment requires a box to build off of.
    network_config.vm.box       = "precise64"

    # Puppet wants a hostname that is FQDN
    network_config.vm.hostname = "network.local"

    # The url from where the 'config.vm.box' box will be fetched if it
    # doesn't already exist on the user's system.
    network_config.vm.box_url = "http://files.vagrantup.com/precise64.box"


    # Execute the installation scripts (via SSH)
    network_config.vm.provision :shell, :inline => "cd /vagrant && ./vagrant-network-bootstrap.sh"

  end
  
  #============================
  # Monitor Node: Running Ganglia and Spluk
  #----------------------------
  config.vm.define :monitor do |monitor_config|

    # Every Vagrant virtual environment requires a box to build off of.
    monitor_config.vm.box       = "precise64"

    # Puppet wants a hostname that is FQDN
    monitor_config.vm.hostname = "monitor.local"

    # The url from where the 'config.vm.box' box will be fetched if it
    # doesn't already exist on the user's system.
    monitor_config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    
    monitor_config.vm.provision :puppet do |puppet|
      puppet.manifests_path = 'puppet/manifests'
      puppet.module_path    = 'puppet/modules'
    end


  end
  

end
