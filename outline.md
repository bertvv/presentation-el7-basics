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

