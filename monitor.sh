#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Check systemd unit status and if stopped then try to start / restart

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Initial variables
# ---------------------------------------------------\

# Script has argument or not
_SVC=$@
# Def status
_STAT=0

# Help
usage() {
    echo -e "Pass service name as argument please"
    exit 1
}

# Checking active status from systemd unit
checkSVC() {
    systemctl is-active $_SVC >/dev/null 2>&1 && _STAT=1 # || _STAT=0
}

# Action
checkSTAT() {

    checkSVC

    if [[ "$_STAT" -eq "1" ]]; then
    
        echo -e "Service: $_SVC still running"
        
    else

        echo -e "Service: $_SVC has stopped status"

    fi
}

# Argument passing
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    usage
else
    checkSTAT
fi