#!/bin/bash


MY_DIR=`dirname $0`


if [[ -f vagrant-common.sh ]]
then

    . vagrant-common.sh
else
    echo "Configuratin file not found: vagrant-common.sh"
    exit 1
fi


echo "================================"
echo "Running: vagrant-controller-bootstrap.sh"
echo "DIR: ${MY_DIR}"
echo "--------------------------------"


# Ensure git is installed
sudo apt-get update
sudo apt-get -y install git

# git clone OpenStackInstaller
# git clone https://github.com/uksysadmin/OpenStackInstaller.git
# cd OpenStackInstaller
# git checkout folsom

sed -i 's/192.168.1.12/${MYSQL_SERVER_IP}/g' openstack.conf
./folsom/install-folsom.sh controller
echo "${COMPUTE_NODE_IP} compute-node" >> /etc/hosts
