# Monitor.sh - Script for checking systemd unit status

And `monitor.sh` can run custom script / action if unit has stopped or running statuses

You can use multiple argument for checking and actions depends from result `is-astatus` status:

```bash
./monitor.sh -u sshd -a "/path/to/action-script/action.sh"
````