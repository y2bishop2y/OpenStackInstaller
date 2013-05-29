#!/bin/bash


MY_DIR=`dirname $0`

echo "================================"
echo "Running: vagrant-controller-bootstrap.sh"
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
sudo apt-get -y install emacs23


# sed -i 's/192.168.1.12/${MYSQL_SERVER_IP}/g' openstack.conf

cd folsom
./install-folsom.sh controller

echo "================================"
echo "${COMPUTE_NODE_IP} compute-node" >> /etc/hosts
echo "--------------------------------"
echo "" 
echo "================================"
echo "nameserver 10.11.50.31" >> /etc/resolv.conf
echo "nameserver 10.11.50.41" >> /etc/resolv.conf
echo "--------------------------------"
