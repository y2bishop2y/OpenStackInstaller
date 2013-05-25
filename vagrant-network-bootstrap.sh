#!/bin/bash

MY_DIR=`dirname $0`


echo "================================"
echo "Running: vagrant-network-bootstrap.sh"
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

