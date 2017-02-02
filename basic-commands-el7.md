% Basic commands for EL7
% Bert Van Vreckem
% CentOS Dojo 2017 Brussels, 2017-02-03

# Intro

## `whoami`

- Bert Van Vreckem
- *Lector ICT* at University College Ghent (HoGent)
    - BS programme Applied Informatics
    - Mainly Linux, research techniques
- *Open source* contributor: <https://github.com/bertvv/>
    - Ansible roles
    - Scripts
    - ...

## This talk is for you if you're

- (Relatively) new to Linux/CentOS
- Still struggling with the recent changes EL7

## Agenda

- Network settings (`ip`)
- Managing services (`systemctl`)
- Show system logs (`journalctl`)
- Show sockets (`ss`)
- Firewall configuration (`firewalld`)
- Troubleshooting (including *SELinux*)

## Remarks

- "Old" commands are (mostly) not mentioned
    - <https://fedoraproject.org/wiki/SysVinit_to_Systemd_Cheatsheet>
- I'm neutral w.r.t. systemd, etc. I won't discuss "politics" here!
- **Interrupt me if you have remarks/questions!**

Presentation, example code:

<https://github.com/bertvv/presentation-el7-basics/>

## Case: web + db server

Two VirtualBox VMs, set up with Vagrant

| Host  | IP            | Service              |
| :---  | :---          | :---                 |
| `web` | 192.168.56.72 | http, https (Apache) |
| `db`  | 192.168.56.73 | mysql (MariaDB)      |

- On `web`, a PHP app runs a query on the `db`
- `db` is set up correctly, `web` is not

---

```
$ git clone https://github.com/bertvv/presentation-el7-basics.git
$ cd presentation-el7-basics
$ vagrant status
Current machine states:

db                        not created (virtualbox)
web                       not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
$ vagrant up
```

# Network settings

## `ip`

| Task                | Command              |
| :---                | :---                 |
| NIC status          | `ip link`            |
| IP addresses        | `ip address`, `ip a` |
| for specific device | `ip a show dev em1`  |
| Routing info        | `ip route`, `ip r`   |

## Example (VirtualBox VM)

```
$ ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether 08:00:27:8e:91:e0 brd ff:ff:ff:ff:ff:ff
3: enp0s8: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT qlen 1000
    link/ether 08:00:27:75:a8:2c brd ff:ff:ff:ff:ff:ff
```

---

```
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

(`enp0s8` has no IP, caused by Vagrant [bug #8096](https://github.com/mitchellh/vagrant/issues/8096))

## The new interface names

[Predictable Network Interface Names](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/), since Systemd v197

| Example    | Type                                   |
| :---       | :---                                   |
| `em1`      | EMbedded #                             |
| `eno1`     | EtherNet Onboard adapter #             |
| `p1p1`     | PCI slot # Port #                      |
| `enp0s3`   | Ethernet Network Peripheral # serial # |
| `wlp3s0b1` | Wireless PCI bus # slot #              |

Also, see (Hayden, 2015)

## Configuration

- `systemd-networkd` still reads the traditional `/etc/sysconfig/network-scripts/ifcfg-*`
- After change, restart `network.service` (see below)

---

```bash
# /etc/sysconfig/network-scripts/ifcfg-enp0s3
DEVICE=enp0s3
ONBOOT=yes
BOOTPROTO=dhcp
```

```bash
# /etc/sysconfig/network-scripts/ifcfg-enp0s8
DEVICE=enp0s8
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.56.72
NETMASK=255.255.255.0
```

# Managing services with `systemctl`

## `systemctl`

`systemctl COMMAND [OPTION]... NAME`

| Task                | Command                    |
| :---                | :---                       |
| Status service      | `systemctl status NAME`    |
| Start service       | `systemctl start NAME`     |
| Stop service        | `systemctl stop NAME`      |
| Restart service     | `systemctl restart NAME`   |
| Start at boot       | `systemctl enable NAME`    |
| Don't start at boot | `systemctl disable NAME`   |

Usually, *root permissions* required (`sudo`)

---

Default command: `list-units`

| Task              | Command                     |
| :---              | :---                        |
| List all services | `systemctl --type=service`  |
| Running services  | `systemctl --state=running` |
| Failed services   | `systemctl --failed`        |

# System logs with `systemd-journald`

## `journalctl`

- `journalctl` requires *root permissions*
    - Or, add user to group `adm` or `systemd-journal`
- Some "traditional" text-based log files still exist (for now?):
    - `/var/log/messages` (gone in Fedora!)
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

| Task                 | Command                |
| :---                 | :---                   |
| Show server sockets  | `ss -l`, `--listening` |
| Show TCP sockets     | `ss -t`, `--tcp`       |
| Show UDP sockets     | `ss -u`, `--udp`       |
| Show port numbers(*) | `ss -n`, `--numeric`   |
| Show process(†)      | `ss -p`, `--processes` |

(*) instead of service names from `/etc/services`

(†) *root permissions* required

## Example

```
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

## Static vs dynamic firewall model

- *ip(6)tables* service: static
    - change => rule flush + daemon restart
    - broke stateful firewalling, established connections
- *firewalld*: dynamic
    - changes applied directly, no lost connections
- Both use iptables/netfilter in the background!
- Tools that depend on "old" model may cause problems
    - e.g. `docker-compose` (Issue [#2841](https://github.com/docker/compose/issues/2841))

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
| Show current rules           | `firewall-cmd --list-all`            |

`firewall-cmd` requires *root permissions*

## Configuring firewall rules

| Task                     | Command                            |
| :---                     | :---                               |
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

## Gotcha

Zone assignments may be overwritten at boot time (CentOS [issue #7407](https://bugs.centos.org/view.php?id=7407))

Reproduce:

1. Remove interface from public zone

```
$ sudo firewall-cmd --get-active-zones
public
  interfaces: enp0s3 enp0s8
$ sudo firewall-cmd --remove-interface=enp0s3
success
[vagrant@db ~]$ sudo firewall-cmd --get-active-zones
public
  interfaces: enp0s8
```

---

2. Reboot, then:

```
$ sudo firewall-cmd --get-active-zones
public
  interfaces: enp0s3
```

- Cause: `/etc/sysconfig/network-scripts/ifup-eth`
- Workaround: remove `firewall-cmd` invocation

# Troubleshooting

## General guidelines

- Follow TCP/IP (or OSI) stack
- Bottom-up:
    1. Link layer
    2. Internet layer
    3. Transport layer
    4. Application layer
- Know your network, i.e. expected values
- Be thorough, check assumptions

Goal: see the web page at <http://192.168.56.72/test.php>

## Checklist: Link layer

- bare metal:
    - test the cable(s)
    - check switch/NIC LEDs
- VM (e.g. VirtualBox):
    - check Adapter type & settings
- `ip link`

## Checklist: Internet layer

- Local settings:
    - IP address: `ip a`
    - Default gateway: `ip r`
    - DNS service: `/etc/resolv.conf`
- LAN connectivity:
    - Ping between hosts
    - Ping default GW/DNS
    - Query DNS (`dig`, `nslookup`, `getent`)

## Checklist: Transport layer

- Service running? `sudo systemctl status SERVICE`
- Correct port/interface? `sudo ss -tulpn`
- Firewall settings? `sudo firewall-cmd --list-all`

## Checklist: Application layer

- Check the logs `sudo journalctl -f -u SERVICE`
- Check config file syntax

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

## Boolean settings

| Task                     | Command                     |
| :---                     | :---                        |
| List all boolean values  | `getsebool -a`              |
| List http-related values | `getsebool -a | grep httpd` |
| Show specific value      | `getsebool VAR`             |
| Set value                | `setsebool VAR on`          |
| Persistent               | `setsebool -P VAR on`       |

## File context

| Task                       | Command                    |
| :---                       | :---                       |
| Show SELinux context       | `ls -Z`                    |
| Reset context              | `restorecon PATH`          |
| Reset context recursively  | `restorecon -R PATH`       |
| Change context recursively | `chcon -t CONTEXT -R PATH` |

Example of adding a context rule:

```
$ sudo semanage fcontext -a -t httpd_sys_content_t "/srv/www(/.*)?"
$ cat /etc/selinux/targeted/contexts/files/file_contexts.local
```

## Creating a policy

Let's try to set `DocumentRoot "/vagrant/www"`

```
$ sudo vi /etc/httpd/conf/httpd.conf
$ ls -Z /vagrant/www/
-rw-rw-r--. vagrant vagrant system_u:object_r:vmblock_t:s0   test.php
$ sudo chcon -R -t httpd_sys_content_t /vagrant/www/
chcon: failed to change context of ‘test.php’ to ‘system_u:object_r:httpd_sys_content_t:s0’: Operation not supported
chcon: failed to change context of ‘/vagrant/www/’ to ‘system_u:object_r:httpd_sys_content_t:s0’: Operation not supported
```

## Creating a policy

Instead of setting the files to the expected context, allow httpd to access files with `vmblock_t` context

1. Allow Apache to run in "permissive" mode:

    ```
    $ sudo semanage permissive -a httpd_t
    ```

2. Generate "Type Enforcement" file (.te)

    ```
    $ sudo audit2allow -a -m httpd-vboxsf > httpd-vboxsf.te
    ```

3. If necessary, edit the policy

    ```
    $ sudo vi httpd-vboxsf.te
    ```

---

1. Convert to policy module (.pp)

    ```
    $ checkmodule -M -m -o httpd-vboxsf.mod httpd-vboxsf.te
    $ semodule_package -o httpd-vboxsf.pp -m httpd-vboxsf.mod
    ```

5. Install module

    ```
    $ sudo semodule -i httpd-vboxsf.pp
    ```

6. Remove permissive domain exception

    ```
    $ sudo semanage permissive -d httpd_t
    ```

Tip: automate this!

# That's it!

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
- Jahoda, M., et al. (2016a) [RHEL 7 Security Guide](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/index.html)
- Jahoda, M., et al. (2016b) [RHEL 7 SELinux User's and Administrator's Guide](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/SELinux_Users_and_Administrators_Guide/index.html)
- Svistunov, M., et al. (2016) [RHEL 7 System Administrator's Guide](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/index.html)
- Van Vreckem, B. (2015) [Enterprise Linux 7 Cheat sheet](https://github.com/bertvv/cheat-sheets/blob/master/src/EL7.md)
- Van Vreckem, B. (2017) [Network troubleshooting guide](https://github.com/bertvv/cheat-sheets/blob/master/src/NetworkTroubleshooting.md)
