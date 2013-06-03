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
sudo apt-get -y install emacs23 


cd folsom
./install-folsom.sh compute

echo "================================"
echo "Setting up hosts file" 
echo "${CONTROLLER_NODE_IP} controller" >> /etc/hosts
echo "--------------------------------"
echo "" 
echo "================================"
echo "nameserver 10.11.50.31" >> /etc/resolv.conf
echo "nameserver 10.11.50.41" >> /etc/resolv.conf
echo "--------------------------------"
