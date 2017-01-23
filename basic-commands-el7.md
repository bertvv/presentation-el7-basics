% Basic commands for EL7
% Bert Van Vreckem
% CentOS Dojo 2017 Brussels, 2017-02-03

# Agenda

## Agenda

- Network settings (`ip`)
- Managing services with `systemctl`
- Show system logs with `journalctl`
- Show sockets (`ss`)
- Firewall configuration with `firewalld`
- SELinux troubleshooting

## `whoami`

- Bert Van Vreckem
- Lector ICT at University College Ghent (HoGent)
    - BS programme Applied Informatics
    - Mainly Linux, research techniques

# Network settings

## `ip`

| Task                | Command              |
| :---                | :---                 |
| NIC status          | `ip link`            |
| IP addresses        | `ip address`, `ip a` |
| for specific device | `ip a show dev em1`  |
| Routing info        | `ip route`, `ip r`   |

## Example (VirtualBox VM)

```ShellSession
$ ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether 08:00:27:8e:91:e0 brd ff:ff:ff:ff:ff:ff
3: enp0s8: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT qlen 1000
    link/ether 08:00:27:75:a8:2c brd ff:ff:ff:ff:ff:ff
```

---

```ShellSession
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 08:00:27:8e:91:e0 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 86349sec preferred_lft 86349sec
    inet6 fe80::a00:27ff:fe8e:91e0/64 scope link 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
    link/ether 08:00:27:75:a8:2c brd ff:ff:ff:ff:ff:ff
```

## The new interface names

[Predictable Network Interface Names](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/), since Systemd v197

| Example    | Type                                   |
| :---       | :---                                   |
| `em1`      | EMbedded #                             |
| `eno1`     | EtherNet Onboard adapter #             |
| `p1p1`     | PCI slot # Port #                      |
| `enp0s3`   | Ethernet Network Peripheral # serial # |
| `wlp3s0b1` | Wireless PCI bus # slot #              |

## Configuration

`systemd-networkd` still uses the traditional `/etc/sysconfig/network-scripts/ifcfg-*`

```
# /etc/sysconfig/network-scripts/ifcfg-enp0s3
DEVICE=enp0s3
ONBOOT=yes
BOOTPROTO=dhcp
```

---

```
# /etc/sysconfig/network-scripts/ifcfg-enp0s8
DEVICE=enp0s8
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.56.72
NETMASK=255.255.255.0
```

# Managing services with `systemctl`

## `systemctl`

`systemctl [OPTION]... COMMAND [NAME]...`

| Task                | Command                    |
| :---                | :---                       |
| Status service      | `systemctl status NAME`    |
| Start service       | `systemctl start NAME`     |
| Stop service        | `systemctl stop NAME`      |
| Restart service     | `systemctl restart NAME`   |
| Start at boot       | `systemctl enable NAME`    |
| Don't start at boot | `systemctl disable NAME`   |

Usually, root permissions required (`sudo`)

---

Default command: `list-units`

| Task                | Command                    |
| :---                | :---                       |
| List all services   | `systemctl --type=service` |
| Failed services     | `systemctl --failed`       |

# System logs with `systemd-journald`

## `journalctl`

- `journalctl` needs root permissions
    - Or, add user to group `adm` or `systemd-journal`
- Some "traditional" text-based log files still exist (for now?):
    - `/var/log/messages`
    - `/var/log/httpd/access_log` and `error_log`
    - ...

## Options

| Action                               | Command                                   |
| :---                                 | :---                                      |
| Show latest log and wait for changes | `journalctl -f`, `--follow`               |
| Show only log of SERVICE             | `journalctl -u SERVICE`, `--unit=SERVICE` |
| Match executable, e.g. `dhclient`    | `journalctl /usr/sbin/dhclient`           |
| Match device node, e.g. `/dev/sda`   | `journalctl /dev/sda`                     |
| Show auditd logs                     | `journalctl _TRANSPORT=audit`             |

---

| Action                         | Command                               |
| :---                           | :---                                  |
| Show log since last boot       | `journalctl -b`, `--boot`             |
| Kernel messages (like `dmesg`) | `journalctl -k`, `--dmesg`            |
| Reverse output (newest first)  | `journalctl -r`, `--reverse`          |
| Show only errors and worse     | `journalctl -p err`, `--priority=err` |
| Since yesterday                | `journalctl --since=yesterday`        |

---

Filter on time (example):

```
journalctl --since=2014-06-00 \
           --until="2014-06-07 12:00:00"
```

Much more options in the man-page!

# Show open sockets

## Show sockets: `ss`

- `netstat` is obsolete, replaced by `ss`
    - `netstat` uses `/proc/net/tcp`
    - `ss` directly queries the kernel
- Similar options

## Options

| Task                 | Command |
| :---                 | :---    |
| Show server sockets  | `ss -l` |
| Show TCP sockets     | `ss -t` |
| Show UDP sockets     | `ss -u` |
| Show port numbers(*) | `ss -n` |
| Show process(†)      | `ss -p` |

(*) instead of service names from `/etc/services`

(†) root permissions required

## Example

```ShellSession
$ sudo ss -tlnp
State   Recv-Q Send-Q Local Address:Port Peer Address:Port
LISTEN  0      128                *:22              *:*    users:(("sshd",pid=1290,fd=3))
LISTEN  0      100        127.0.0.1:25              *:*    users:(("master",pid=1685,fd=13))
LISTEN  0      128               :::80             :::*    users:(("httpd",pid=4403,fd=4),("httpd",pid=4402,fd=4),("httpd",pid=4401,fd=4),("httpd",pid=4400,fd=4),("httpd",pid=4399,fd=4),("httpd",pid=4397,fd=4))
LISTEN  0      128               :::22             :::*    users:(("sshd",pid=1290,fd=4))
LISTEN  0      100              ::1:25             :::*    users:(("master",pid=1685,fd=14))
LISTEN  0      128               :::443            :::*    users:(("httpd",pid=4403,fd=6),("httpd",pid=4402,fd=6),("httpd",pid=4401,fd=6),("httpd",pid=4400,fd=6),("httpd",pid=4399,fd=6),("httpd",pid=4397,fd=6))
```

# Firewall configuration with `firewalld`

## Former static vs dynamic firewall model

- ip(6)tables service: static
    - change => rule flush + daemon restart
    - including reloading kernel modules
    - broke stateful firewalling, established connections
- `firewalld`: dynamic
    - changes applied directly
    - no lost connections

Both use `iptables`/netfilter in the background!

## Zones

- Zone = list of rules to be applied in a specific situation
    - e.g. public (default), home, work, ...
- NICs are assigned to zones
- For a server, `public` zone is probably sufficient

| Task                         | Command                              |
| :---                         | :---                                 |
| List all zones               | `firewall-cmd --get-zones`           |
| Current active zone          | `firewall-cmd --get-active-zones`    |
| Add interface to active zone | `firewall-cmd --add-interface=IFACE` |

! `firewall-cmd` requires root permissions

## Configuring firewall rules

| Task                     | Command                            |
| :---                     | :---                               |
| Show current rules       | `firewall-cmd --list-all`          |
| Allow predefined service | `firewall-cmd --add-service=http`  |
| List predefined services | `firewall-cmd --get-services`      |
| Allow specific port      | `firewall-cmd --add-port=8080/tcp` |
| Reload rules             | `firewall-cmd --reload`            |
| Block all traffic        | `firewall-cmd --panic-on`          |
| Turn panic mode off      | `firewall-cmd --panic-off`         |

## Persistent changes

- `--permanent` option => not applied immediately!
- Two methods:
    1. Execute command once without, once with `--permanent`
    2. Execute command with `--permanent`, reload rules
- First method is faster

```ShellSession
sudo firewall-cmd --add-service=http
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https
sudo firewall-cmd --add-service=https --permanent
```

# SELinux troubleshooting

## SELinux

- SELinux is Mandatory Access Control in the Linux kernel
- Settings:
    - Booleans: `getsebool`, `setsebool`
    - Contexts, labels: `ls -Z`, `chcon`
    - Policy modules: `sepolicy`

## Enabling SELinux

| Task               | Command                |
| :---               | :---                   |
| Get current status | `sestatus`             |
| Get mode           | `getenforce`           |
| Enable SELinux     | `setenforce Enforcing` |

Enable SELinux permanently: `/etc/sysconfig/selinux`

## 

# Thank you!

## Thank you!

- [&#64;bertvanvreckem](https://twitter.com/bertvanvreckem)
- <https://github.com/bertvv>
    - Ansible/Vagrant
    - Course material, lab assignments
- <https://youtube.com/bertvvrhogent/>
    - Linux Screencasts (in Dutch)

# References

## References

- Hayden, M. (2015) [Understanding systemd’s predictable network device names](https://major.io/2015/08/21/understanding-systemds-predictable-network-device-names/)
- Van Vreckem, B. (2015) [Enterprise Linux 7 Cheat sheet](https://github.com/bertvv/cheat-sheets/blob/master/src/EL7.md)
