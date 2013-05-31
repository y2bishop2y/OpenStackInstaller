#!/bin/bash

MY_DIR=`dirname $0`

echo "DIR: ${MY_DIR}"


echo "================================"
echo "Running: vagrant-ovs-bootstrap.sh"
echo "DIR: ${MY_DIR}"
echo "--------------------------------"


if [[ -f vagrant-common.sh ]]
then

    . vagrant-common.sh
else
    echo "Configuratin file not found: vagrant-common.sh"
    exit 1
fi

# Ensure git is installed
sudo apt-get update

cd folsom
./install-ovs.sh
