#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Check systemd unit status and if stopped then try to start / restart

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Initial variables
# ---------------------------------------------------\

# Unit name as argument
_SVC=$@

systemctl is-active $_SVC >/dev/null 2>&1 && _STAT=1 # || _STAT=0

if [[ "$_STAT" -eq "1" ]]; then
    
    echo -e "Service: $_SVC still running"
    
else

    echo -e "Service: $_SVC has stopped status"

fi