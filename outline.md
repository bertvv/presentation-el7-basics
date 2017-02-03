# Basic commands for Enterprise Linux 7

- Network settings
    - `ip`
    - `ip a`, `ip link`, `ip route`
- Managing services
    - `systemctl` status, start, stop, restart, ...
- Show sockets (`ss`, the new `netstat`)
- Firewall
    - `firewall-cmd`
    - Concept of zones: lists of rules, to be used in a specific situation (e.g. at home, at work, in a coffee shop, ...)
    - For a server, typically not needed (default: public)
    - Show rules, `--add-service`, `--add-port`
    - `--permanent`
    - Gotcha: permanent firewall rules are overwritten after reboot.
- System/service logs: `journalctl`
    - Make user member of group `systemd-journald`
    - `-f`, `-u UNIT`, `-b`
- SELinux troubleshooting
    - Don’t disable SELinux
    - `getsebool`, `setsebool`
    - `ls -Z`
    - Finding problems in `audit.log`:
        - `sudo journalctl --boot _TRANSPORT=audit`
    - Compiling a new policy: Allow `vagrant_t`

## Remarks, feedback

During the presentation I received some great feedback & remarks from the audience. An overview:

- New interface names:
    - names are not assigned by `systemd`, but `biosdevname`
    - `em1`, `p1p1` are typical for Dell
- Check systemd unit files:
    - `sudo systemd-analyze verify /usr/lib/systemd/system/httpd.service`
    - Simulates what would happen on `systemctl start`
    - Doesn't (as of yet) check the syntax of the service itself, but maybe something to add...
- `journalctl _TRANSPORT=audit` will not work in CentOS, only in Fedora
    - CentOS: look at `/var/log/audit/audit.log`
- CentOS bug #7407 will only affect network interfaces that are not managed by NetworkManager (as is the case with Vagrant VMs)
