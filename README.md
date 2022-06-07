# Monitor.sh - Script for checking systemd unit status

And `monitor.sh` can run custom script / action if unit has stopped or running statuses.

If service has stopped status, you can recover this unit service and run custom script:
```bash
./monitor.sh -u multipathd -r -a "/usr/local/sbin/test.sh"
```

OR just only `-r` for recovery unit:
```
./monitor.sh -u multipathd -r
```

You can use just script if service has `stopped` status:

```bash
./monitor.sh -u sshd -a "/path/to/action-script/action.sh"
````

OR check unit without actions:

```
./monitor.sh -u sshd
```

TODO: send status to Telegram