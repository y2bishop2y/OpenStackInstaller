#!/bin/bash


echo "================================"
echo "Running: folsom-quantum-agent.sh"
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


NTP_CONF=/etc/ntp.conf

QUANTUM_CONF=/etc/quantum/quantum.conf
OVS_QUANTUM_PLUGIN_INI=/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini

function quantum_agent_install() {
	sudo apt-get -y install linux-headers-`uname -r` quantum-plugin-openvswitch-agent openvswitch-datapath-source
	sudo apt-get -y install pm-utils

	sudo module-assistant auto-install openvswitch-datapath
}

function quantum_agent_configure() {
    #===========================
    # quantum.conf
    #---------------------------
    sudo sed -i "s/^# auth_strategy.*/auth_strategy = keystone/g"       ${QUANTUM_CONF}
    sudo sed -i "s/^# fake_rabbit.*/fake_rabbit = False/g"              ${QUANTUM_CONF}
    sudo sed -i "s/^debug.*/debug = False/g"                            ${QUANTUM_CONF}
    sudo sed -i "s/^verbose.*/verbose = False/g"                        ${QUANTUM_CONF}

    sudo sed -i "s/^# rabbit_host.*/rabbit_host = ${RABBIT_ENDPOINT}/g" ${QUANTUM_CONF}
    sudo sed -i "s/^# rabbit_port.*/rabbit_port = ${RABBIT_PORT}/g"     ${QUANTUM_CONF}

    #===========================
    # ovs_quantum_plugin.ini
    #---------------------------
    sudo rm -f $OVS_QUANTUM_PLUGIN_INI
    cat >/tmp/ovs_quantum_plugin.ini << EOF
[DATABASE]
sql_connection = mysql://quantum:$MYSQL_DB_PASS@$MYSQL_SERVER:3306/quantum
reconnect_interval = 2
[OVS]
#=========================
# VLAN
#-------------------------
tenant_network_type=vlan
network_vlan_ranges = ${PHYSICAL_NETWORK_NAME}:1:4094
bridge_mappings = physnet1:br-${PRIVATE_INTERFACE}

[AGENT]
root_helper = sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf
EOF

    sudo mv /tmp/ovs_quantum_plugin.ini ${OVS_QUANTUM_PLUGIN_INI}
    sudo chown quantum:quantum          ${OVS_QUANTUM_PLUGIN_INI}
    sudo chmod 644                      ${OVS_QUANTUM_PLUGIN_INI}

    #===========================
    # /etc/ntp.conf
    #---------------------------
    sudo sed -i "s/^server ntp.ubuntu.com/server ${QUANTUM_ENDPOINT}/g" ${NTP_CONF}


}

function quantum_agent_restart() {
    sudo service openvswitch-switch stop
    sudo service openvswitch-switch start
    sudo service quantum-plugin-openvswitch-agent stop
    sudo service quantum-plugin-openvswitch-agent start

    sudo service ntp restart

}

function ovs_configure() {
    # VM Communication network bridge
    sudo ovs-vsctl add-br   ${INT_BRIDGE}
    
    sudo ovs-vsctl add-br   br-${PRIVATE_INTERFACE}
    sudo ovs-vsctl add-port br-${PRIVATE_INTERFACE} ${PRIVATE_INTERFACE}

}


#=========================
# Main
#-------------------------
quantum_agent_install
quantum_agent_configure

ovs_configure



quantum_agent_restart



