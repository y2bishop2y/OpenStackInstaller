#!/bin/bash

MY_DIR=`dirname $0`


echo "================================"
echo "Running: vagrant-openstack-bootstrap.sh"
echo "DIR: ${MY_DIR}" 
echo "--------------------------------"


if [[ -f vagrant-common.sh ]]
then

    . vagrant-common.sh
else
    echo "Configuration file not found: vagrant-common.sh"
    exit 1
fi



# Ensure git is installed
sudo apt-get update
sudo apt-get -y install git

# sed -i 's/192.168.1.12/${MYSQL_SERVER_IP}/g' openstack.conf

cd folsom
./install-folsom.sh
