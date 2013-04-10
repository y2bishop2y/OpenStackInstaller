#!/bin/bash

MY_DIR=`dirname $0`


echo "================================"
echo "Running: vagrant-compute-bootstrap.sh"
echo "DIR :${MY_DIR}"
echo "--------------------------------"


if [[ -f vagrant-common.sh ]]
then

    . vagrant-common.sh
else
    echo "================================"
    echo "[ERROR] Configuration file not found: vagrant-common.sh"
    echo "--------------------------------"
    exit 1
fi



# Ensure git is installed
sudo apt-get update
sudo apt-get -y install git

# git clone OpenStackInstaller
# git clone https://github.com/uksysadmin/OpenStackInstaller.git
# cd OpenStackInstaller
# git checkout folsom


# sed -i 's/192.168.1.12/${MYSQL_SERVER_IP}/g' openstack.conf

cd folsom
./install-folsom.sh compute

echo "================================"
echo "Setting up hosts file" 
echo "${CONTROLLER_NODE_IP} controller-node" >> /etc/hosts
echo "--------------------------------"
