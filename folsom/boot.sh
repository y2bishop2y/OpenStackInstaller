#!/bin/bash

# nova keypair-add test > test.pem
# chmod 600 test.pem
# nova boot --image cirros-0.3.0-x86_64 --flavor m1.small --key_name test my-first-server

nova keypair-add test2 > test2.pem
chmod 600 test2.pem
nova boot --image cirros-0.3.0-x86_64 --flavor m1.small --key_name test2 my-first-server2
