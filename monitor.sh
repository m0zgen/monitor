#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Check systemd unit status and if stopped then try to start / restart

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Initial variables
# ---------------------------------------------------\

_STAT=0

# Init
# ---------------------------------------------------\

# Help
usage() {
    echo -e "Pass service name as argument please:
    -u - unit name
    -a - path to bash action script
    -
    "
    exit 1
}

# Argument passing
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    usage
fi

# Checks arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--unit)      _UNIT_NAME=1; _SERVICE="$2"; shift;;
        -a|--action)    _ACTION=1 _SCRIPT="$2"; shift;;
        -i|--is)    _IS=1 _IS_BOOL="$2"; shift;;
        -r|--recover) _RECOVER=1 ;;
        -h|--help) usage ;; 
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Functions
# ---------------------------------------------------\

# Checking active status from systemd unit
checkSVC() {
    _SVC=$1
    systemctl is-active $_SVC >/dev/null 2>&1 && _STAT=1 # || _STAT=0
}

runAction() {

    if [[ -n "$_ACTION" ]]; then
            echo -e "Try to run action script..."

            if [[ -f  "$_ACTION" ]]; then
                bash $_ACTION
            else
                echo -e "Action script does not found. Exit."
                exit 1
            fi

        fi
}

checkSCRIPT() {
    if [[ ! -f $1 ]]; then
        echo -e "Action starter script does not found."
    else
        bash $1
    fi
}

service_exists() {
    local n=$1
    if [[ $(systemctl list-units --all -t service --full --no-legend "$n.service" | sed 's/^\s*//g' | cut -f1 -d' ') == $n.service ]]; then
        return 0
    else
        return 1
    fi
}

service_enabled() {
    local n=$1
    if [[ `systemctl is-enabled "$n"` ]]; then
        return 0
    else
        return 1
    fi
}

# Action
checkSTAT() {

    checkSVC $1

    if [[ "$_STAT" -eq "1" ]]; then
    
        echo -e "Service: $_SVC still running"
        
    else

        if service_exists $_SVC; then

            echo -e "Service: $_SVC has stopped status"

            if [[ "$_ACTION" -eq "1" ]]; then

                if [[ -z "$_SCRIPT" ]]; then
                    echo "Please set -a action runner script path."
                else
                    checkSCRIPT $_SCRIPT
                fi
            fi 

            if [[ "$_RECOVER" -eq 1 ]]; then

                if service_exists $_SVC; then
                systemctl enable --now $_SVC

                fi
                systemctl restart $_SVC
            fi
        else
            echo -e "Systemd unit $_SVC does not exist"
        fi

        

    fi
}

# Runner
# ---------------------------------------------------\

if [[ "$_UNIT_NAME" -eq "1" ]]; then

    if [[ -z "$_SERVICE" ]]; then
        echo "Please set unit.service name in -u."
    else
        checkSTAT $_SERVICE
    fi
fi
