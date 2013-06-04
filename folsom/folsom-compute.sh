#!/bin/bash

echo "================================"
echo "Running: folsom-compute.sh"
echo "--------------------------------"


# Source in configuration file
if [[ -f openstack.conf ]]
then
    . openstack.conf
else
    echo "================================"
    echo "[ERROR] Configuration file not found. Please create openstack.conf"
    echo "--------------------------------"
    exit 1
fi

NOVA_CONF=/etc/nova/nova.conf
NOVA_COMPUTE_CONF=/etc/nova/nova-compute.conf
NOVA_API_PASTE=/etc/nova/api-paste.ini


QEMU_CONF=/etc/libvirt/qemu.conf

LIBVIRTD_CONF=/etc/libvirt/libvirtd.conf
LIBVIRT_INIT_CONF=/etc/init/libvirt-bin.conf
LIBVIRT_DEFAULT_CONF=/etc/default/libvirt-bin

nova_compute_install() {
    sudo apt-get -y install nova-api-metadata nova-compute nova-compute-qemu nova-doc

    #-- Because I need a real editor
    sudo apt-get -y install emacs23
}

nova_configure() {
    cat > /tmp/nova.conf << EOF
[DEFAULT]
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/run/lock/nova
allow_admin_api=true
debug = False
verbose = False
api_paste_config=/etc/nova/api-paste.ini
# SimpleScheduler has been deprecated in Folsom
# scheduler_driver=nova.scheduler.simple.SimpleScheduler
scheduler_driver=nova.scheduler.chance.ChanceScheduler
s3_host=$SWIFT_ENDPOINT
ec2_host=$EC2_ENDPOINT
ec2_dmz_host=$EC2_ENDPOINT
rabbit_host=$RABBIT_ENDPOINT
cc_host=$NOVA_ENDPOINT
nova_url=http://$NOVA_ENDPOINT:8774/v1.1/
sql_connection=mysql://nova:$MYSQL_DB_PASS@$MYSQL_SERVER/nova
ec2_url=http://$EC2_ENDPOINT:8773/services/Cloud
rootwrap_config=/etc/nova/rootwrap.conf

#======================
# Auth
#----------------------
use_deprecated_auth=false
auth_strategy=keystone
keystone_ec2_url=http://$KEYSTONE_ENDPOINT:5000/v2.0/ec2tokens

#======================
# Imaging service
glance_api_servers=$GLANCE_ENDPOINT:9292
image_service=nova.image.glance.GlanceImageService

#======================
# Virt driver
#----------------------
compute_driver = libvirt.LibvirtDriver
libvirt_type=$LIBVIRT_TYPE

libvirt_ovs_bridge=br-eth2
libvirt_vif_type=ethernet

libvirt_vif_driver=nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver
libvirt_use_virtio_for_bridges=True

start_guests_on_host_boot=false
resume_guests_state_on_host_boot=false

#======================
# Vnc configuration
#----------------------
novnc_enabled=true
novncproxy_base_url=http://$NOVA_ENDPOINT:6080/vnc_auto.html
novncproxy_port=6080
# The address of the compute NODE Have move this to a config
vncserver_proxyclient_address=192.168.0.202
vncserver_listen=0.0.0.0
# vncserver_proxyclient_address=$NOVA_ENDPOINT
# vncserver_listen=$NOVA_ENDPOINT

#======================
# Network settings
#----------------------
#dhcpbridge_flagfile=/etc/nova/nova.conf
#dhcpbridge=/usr/bin/nova-dhcpbridge
#network_manager=nova.network.manager.VlanManager
#public_interface=$PUBLIC_INTERFACE
#vlan_interface=$PRIVATE_INTERFACE
#vlan_start=$VLAN_START
#fixed_range=$PRIVATE_RANGE
#routing_source_ip=$NOVA_ENDPOINT
#network_size=1

network_api_class=nova.network.quantumv2.api.API
quantum_url=http://$QUANTUM_ENDPOINT:9696
quantum_auth_strategy=keystone
quantum_admin_tenant_name=$SERVICE_TENANT
quantum_admin_username=quantum
quantum_admin_password=$SERVICE_PASS
quantum_admin_auth_url=http://$KEYSTONE_ENDPOINT:35357/v2.0



linuxnet_interface_driver=nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
force_dhcp_release=True
multi_host=True

#======================
# Cinder #
#----------------------
iscsi_helper=tgt
iscsi_ip_address=$CINDER_ENDPOINT
volume_api_class=nova.volume.cinder.API
osapi_volume_listen_port=5900
EOF

    sudo rm -f $NOVA_CONF
    sudo mv /tmp/nova.conf $NOVA_CONF
    sudo chmod 0640 $NOVA_CONF
    sudo chown nova:nova $NOVA_CONF

    # Paste file
    sudo sed -i "s/127.0.0.1/${KEYSTONE_ENDPOINT}/g"          ${NOVA_API_PASTE}
    sudo sed -i "s/%SERVICE_TENANT_NAME%/${SERVICE_TENANT}/g" ${NOVA_API_PASTE}
    sudo sed -i "s/%SERVICE_USER%/nova/g"                     ${NOVA_API_PASTE}
    sudo sed -i "s/%SERVICE_PASSWORD%/${SERVICE_PASS}/g"      ${NOVA_API_PASTE}


    #===========================
    # nova-compute.conf
    #---------------------------
    # sudo sed -i "\$alibvirt_ovs_bridge=br-eth2"  ${NOVA_COMPUTE_CONF}
    # sudo sed -i "\$alibvirt_vif_type=ethernet"  ${NOVA_COMPUTE_CONF}
    # sudo sed -i "\$alibvirt_vif_driver=nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver"  ${NOVA_COMPUTE_CONF}
    # sudo sed -i "\$alibvirt_use_virtio_for_bridges=True"  ${NOVA_COMPUTE_CONF}

    #===========================
    # qemu.conf
    #---------------------------
    sudo sed -i 's/^#cgroup_device_acl = \[\s*/cgroup_device_acl = \[/g'   ${QEMU_CONF}
    sudo sed -i 's/^#.*"\/dev\/null",\s*"\/dev\/full",\s*"\/dev\/zero",\s*$/  "\/dev\/null", "\/dev\/full", "\/dev\/zero",/g' ${QEMU_CONF}
    sudo sed -i 's/^#.*"\/dev\/random",\s*"\/dev\/urandom",\s*$/  "\/dev\/random", "\/dev\/urandom",/g' ${QEMU_CONF}
    sudo sed -i 's/^#.*"\/dev\/ptmx",\s*"\/dev\/kvm",\s*"\/dev\/kqemu",\s*$/  "\/dev\/ptmx", "\/dev\/kvm", "\/dev\/kqemu",/g' ${QEMU_CONF}
    sudo sed -i 's/^#.*"\/dev\/rtc",\s*"\/dev\/hpet"\s*$/  "\/dev\/rtc", "\/dev\/hpet", "\/dev\/net\/tun"/g' ${QEMU_CONF}
    sudo sed -i 's/^#\]/\]/g' ${QEMU_CONF}


    #===========================
    # libvirtd
    # NOTE: "none" is used just for a TEST / DEV env 
    #---------------------------
    sudo sed -i "s/^#listen_tls = 0/listen_tls = 0/g" ${LIBVIRTD_CONF}
    sudo sed -i "s/^#listen_tcp = 1/listen_tcp = 1/g" ${LIBVIRTD_CONF}
    sudo sed -i "s/^#auth_tcp = /auth_tcp = \"none\"  # NOTE this is only for testing/g" ${LIBVIRTD_CONF}


    #===========================
    # Add the -l options so deamon 
    # can listen for TCP/IP connections
    #===========================
    sudo sed -i "s/^env libvirtd_opts=\"-d\"/env libvirtd_opts=\"-d -l\"/g" ${LIBVIRT_INIT_CONF}

    sudo sed -i "s/libvirtd_opts=\"-d\"/libvirtd_opts=\"-d -l\"/g"          ${LIBVIRT_DEFAULT_CONF}


    #===========================
    # Run all the commands
    #---------------------------
    sudo nova-manage db sync

    # ERB TEMP
    # sudo virsh net-destroy  default
    # sudo virsh net-undefine default
    # sudo service libvirt-bin restart

}

nova_restart() {
    for P in $(ls -la /etc/init/nova* | cut -d'/' -f4 | cut -d'.' -f1)
    do
	sudo stop ${P} 
	sudo start ${P}
    done
}

# Main
nova_compute_install
nova_configure
nova_restart
