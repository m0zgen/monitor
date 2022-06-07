#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Check systemd unit status and if stopped then try to start / restart

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

_SVC=$@
systemctl -q is-active "$_SVC.service"

_STAT=$?
if [ "$_STAT" == 0 ]; then
    echo "OK. Service $_SVC is running."
else
    echo "Fail. Service $_SVC is not running."
fi