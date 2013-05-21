#!/bin/bash 



#============================
# GLOBALS
#----------------------------
# SERVICES_NOVA=(nova-api nova-cert nova-consoleauth nova-novncproxy nova-objectstore nova-scheduler nova-volume)
SERVICES_NOVA=(nova-api nova-cert nova-consoleauth nova-novncproxy)

SERVICES_CINDER=(cinder-api cinder-scheduler cinder-volume)

SERVICES_QUANTUM=(quantum-server  quantum-plugin-openvswitch-agent  quantum-dhcp-agent  quantum-l3-agent)
SERVICES_QUANTUM_AGENT=(openvswitch-switch quantum-plugin-openvswitch-agent)

SERVICES_GLANCE=(glance-api glance-registry)
SERVICES_KEYSTONE=(keystone)

SERVICES_HORIZON=(apache2 memccached)


ACTIONS=("start" "stop" "restart")

#============================
# RUN action loop on passed in services 
# make sure that we shit the action before we get the list 
# items to run 
#----------------------------
function run_loop() {

    local action=$1
    shift
    local services=("${@}")

    # echo "${services[@]}"

    for service in "${services[@]}"
    do
	sudo service  ${service} ${action}
    done 
}

#============================
#----------------------------
function validElement() {


    element=${1}
    shift
    elements=("${@}")


    for i in ${elements[@]}; do 
	if [ $i == $element ]; then
	    # echo "VALID: $i == $element"
	    return 1
	fi
    done
    return 0
}

#============================
#----------------------------
function compute() {

    action=${1}
    echo "=========================" 
    echo "Compute Node [$action]" 
    run_loop ${action} ${SERVICES_QUANTUM_AGENT[@]}
    echo "-------------------------"

}


#============================
#----------------------------
function controller() {

    action=${1}

    echo "=========================" 
    echo "Controller Node [$action]" 
    run_loop ${action} ${SERVICES_KEYSTONE[@]}
    run_loop ${action} ${SERVICES_GLANCE[@]}
    run_loop ${action} ${SERVICES_QUANTUM[@]}
    run_loop ${action} ${SERVICES_CINDER[@]}
    run_loop ${action} ${SERVICES_NOVA[@]}
    # run_loop ${action} ${SERVICES_HORIZON[@]}
    echo "-------------------------"

}

#============================
# MAIN
#----------------------------

echo "=========================" 
echo "Managing OpenStack Nove services" 
echo "-------------------------"
echo ""
if  [ $# == 0 ]; then
    echo "NO arguments passed in, exiting." 
    exit 10
fi

action=
server=
 
while getopts "a:s:" opt; do
    case $opt in
	
	a)
	    action=$OPTARG
	    
	    validElement $action ${ACTIONS[@]}
	    valid=$?

	    if  [[ "1" != $valid ]]  ;
	    then
		echo "Invalid action passed int: $valid"
		echo "Only valid values are [ ${ACTIONS[@]} ]"
		exit -10
	    fi
	    ;;

	s)
	    server=$OPTARG
	    ;;
	\?)
	    echo "Invalid arguments"  >&2
	    exit -10 
	    ;;

	:)
	    echo "$OPTARG requires an argument." >&2
	    exit -10
	    ;;
    esac
done


#============================
# Make sure the server type is correct
#----------------------------
case $server in 
    "controller")
	controller $action
	;;
    
    "compute")
	compute $action
	;;

    *)
	echo "Invalid server type only [controller and compute] are valid values: $server" >&2
	exit -10
	;;

esac
