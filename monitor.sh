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
_CHECK_SCRIPT=$SCRIPT_PATH/tools/check.sh
_AFTER_STAT=0

# Init
# ---------------------------------------------------\

# Help
usage() {
    echo -e "\nPass service name as argument please:
    -u - unit name
    -a - path to bash action script
    -r - recovery unit (enabling and restarting actions)
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
    systemctl is-active $1 >/dev/null 2>&1 && local  _STAT=1 # || _STAT=0

    if [[ "$_STAT" -eq "1" ]]; then
        return 1
        _AFTER_STAT=1
    else
        return 0
    fi
}

setStatus() {
    local n=$1
    if [[ `systemctl is-active "$n"` ]]; then
        return 0
    else
        return 1
    fi
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

is_Action() {
     if [[ "$_ACTION" -eq "1" ]]; then

        if [[ -z "$_SCRIPT" ]]; then
            echo "Please set -a action runner script path."
        else
            checkSCRIPT $_SCRIPT
        fi
    fi
}

is_Bool() {
    local n=$1
    if [[ "$_IS_BOOL" == "true" ]]; then
        return 1
    else
        return 0
    fi
}

# Action
checkSTAT() {

    checkSVC $1

    if [[ "$_STAT" -eq "1" ]]; then
    
        echo -e "Service: $_SVC still running"

        if [[ "$_RECOVER" -eq 1 ]]; then
            echo -e "Recovery not needed"
        fi

        is_Action

        is_Bool $_IS_BOOL
        
    else

        if service_exists $_SVC; then

            echo -e "Service: $_SVC has stopped status"

            is_Action 

            if [[ "$_RECOVER" -eq 1 ]]; then

                if service_exists $_SVC; then
                    echo -e "Enabling $_SVC unit"
                    systemctl enable --now $_SVC
                fi

                echo -e "Restarting $_SVC unit"
                systemctl restart $_SVC; sleep 2

                setStatus

                if [[ "$_AFTER_STAT" -eq 1 ]]; then
                    echo "Service: $_SERVICE successfully started"
                fi

                bash $_CHECK_SCRIPT $_SERVICE
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
