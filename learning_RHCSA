
# Notes for the RHCSA exam EX-200
https://www.redhat.com/de/services/certification/rhcsa?pfe-7d312plns=exams

# Table of Contents
- [Exam Path ](#exam-path-)


# RH124
## Exam Path : 
1. `EX200 RHCSA` -> tests your knowledge and skills in general system administration for a wide variety of environments and development scenarios. You must be an RHCSA to earn certification as a Red Hat Certified Engineer (RHCE®) .
2. `EX294 RHCE` ->  focuses on automation skills and is based on Red Hat Enterprise Linux 8

---
## Links

* `ln` `src_file` `target name` will create a hard link 
* `ln -s` `src_file` `target name` will create a soft link

A hard link will link direct to the inode whereas softlink will link to a filename. With hard links you the source target or src can be removed an and the other will still work unlike with soft links.

---

## Redirecting Input/Output
3 redirects in Linux:

|*redirect*|*descriptor* |
|----------|-------------|
|stdin     |0            |
|stdout    |1            |
|stderr    |2            |

example to redirect `stderr`:
```
[root@centos1 ~]# telnet centos2 21342 2> error.log
[root@centos1 ~]# cat error.log
telnet: centos2: Name or service not known
centos2: Unknown host
```

example to redirect `stderr` to `stdout`:
* Here, `ls` will try to list a non-existent directory. The error message, which would normally go to stderr, but here  it will redirect stderr to the same destination as stdout.
```
[root@centos1 ~]# ls /nonexistentdirectory > output.txt 2>&1
[root@centos1 ~]# cat output.txt
ls: cannot access '/nonexistentdirectory': No such file or directory
[root@centos1 ~]#
```
___
## User management
### Add/modify/delete
to Check if a user exists:
`id <username>`

Commands:
* `useradd <username>` : Will create the user and group with same name and create a homedir permissioned for that user
* `groupadd <groupname>` : will add a group
* `userdel <username>` : will delete a user
* `groupdel <groupname>` : will delete a group
* `usermod <username>` : will modify a user

eg: To Add a user
`useradd -g superheros -s /bin/bash -c "CEO Stark Industries" -m -d /home/ironman ironman`

eg: to change the users shell:
`usermod -s /bin/zsh ironman`

### Password aging

Default config : `/etc/login.defs`
```
                              <---Snippet--->
# Password aging controls:
#
#       PASS_MAX_DAYS   Maximum number of days a password may be used.
#       PASS_MIN_DAYS   Minimum number of days allowed between password changes.
#       PASS_MIN_LEN    Minimum acceptable password length.
#       PASS_WARN_AGE   Number of days warning given before a password expires.
#
PASS_MAX_DAYS   99999
PASS_MIN_DAYS   0
PASS_WARN_AGE   7
                              <---Snippet--->
#
# Min/max values for automatic uid selection in useradd(8)
#
UID_MIN                  1000
UID_MAX                 60000
                              <---Snippet--->
#
ENCRYPT_METHOD SHA512
                              <---Snippet--->
#
# Should login be allowed if we can't cd to the home directory?
# Default is yes.
#
#DEFAULT_HOME   yes
                              <---Snippet--->
#
# If useradd(8) should create home directories for users by default (non
# system users only).
# This option is overridden with the -M or -m flags on the useradd(8)
# command-line.
#
CREATE_HOME     yes

```
The `chage` command changes the number of days between password changes and the date of the last password change. This information is used by the system to determine when a user
       must change their password.

CMDLINE: `chage -d <lastday> -m <mindays> -M <maxdays> -W <warndays> -I -E <expiredate> USERNAME`
* `<last days>` is the # of days since 1970 since last change. Probably wouldnt want to change that, unless needed

eg: `chage -m 5 -M 90 -W 10 -I 3 -E 30 bababutt` results in :
ironman:$6$Sa3CEa7va56INP3Q$zC4sGsgJAn0RjeYfD4Yh5STzc7CSV6oRez3jgb0tvkygUGxa3R.lNgnQvDF/K5W8bQZZUUjWjdDBt4RcOOx2l0:19949:`5`:`90`:`10`:`3`:`30`:

### Sudo 
to add a user to get access to run root commands add the user to group `wheel` :

`usermod -aG wheel aryan`
___

## File Permissions
* you need `execute` rights to `cd` into a directory
* if a file owned by root:root exists in a user directory, the user can remove the file because he is the owner of the directory and has `rwx` on the directory.

___
## Control Services and daemons
* Systemd is the first proc started on the system with PID `1`
```
[root@centos1 ~]# ps  -fp 1
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 Aug13 ?        00:00:06 /usr/lib/systemd/systemd --switched-root --system --deserialize 31
```

* Check all services with `systemctl -all` 
```
[root@centos1 ~]# systemctl -all
  UNIT                                                                                 LOAD      ACTIVE   SUB       DESCRIPTION                                                               >
● boot.automount                                                                       not-found inactive dead      boot.automount
  proc-sys-fs-binfmt_misc.automount                                                    loaded    active   waiting   Arbitrary Executable File Formats File System Automount Point             >
  dev-disk-by\x2ddiskseq-1.device                                                      loaded    active   plugged   /dev/disk/by-diskseq/1
  dev-disk-by\x2ddiskseq-2.device                                                      loaded    active   plugged   /dev/disk/by-diskseq/2
  dev-disk-by\x2dlabel-config\x2d2.device                                              loaded    active   plugged   /dev/disk/by-label/config-2
  dev-disk-by\x2dpartlabel-BIOS\x5cx20Boot\x5cx20Partition.device                      loaded    active   plugged   /dev/disk/by-partlabel/BIOS\x20Boot\x20Partition
  ...  
  ```

### systemctl enable and systemctl disable
These commands are used to control whether a service starts automatically at boot.

* `enable`-  you create a symbolic link in the system’s service directories (usually /etc/systemd/system/) that tells systemd to start the service automatically during boot.
* `disable`- When you disable a service, you remove the symbolic link, so systemd no longer starts the service automatically during boot.

### systemctl mask and systemctl unmask
These commands are used to completely prevent a service from being started, either manually or automatically.

* `mask`- When you mask a service, you create a symbolic link that points to `/dev/null`, effectively blocking the service from being started by any means *(including manually using systemctl start)*.

* `unmask`- When you unmask a service, you remove the symbolic link pointing to /dev/null, allowing the service to be started manually or automatically again.
___

## SSH
### Config
Config : `/etc/ssh/sshd_config`
* Some important config params:

```
ClientAliveInterval 600 # Configure Idle Timeout Interval (auto logout when not used)
ClientAliveCountMax 0 

PermitRootLogin no      # disable root login over ssh
AllowUsers aryan cnory  # restrict ssh to these users

Port 22                 # runs on 22 by default, can be changed
```

### Setup Keys
STEP 1

    ssh- keygen

STEP 2

    ssh-copy-id root@x.x.x.x

STEP 3

    ssh root@x.x.x.x

Best Practise:

The best practice is to generate a separate SSH key pair for each server. Here's why:

<b>Security</b>: If one SSH key is compromised, the attacker gains access to only one direction of communication. This limits potential damage and provides a more granular level of control over access.

<b>Auditability</b>: It becomes easier to manage and audit which keys are in use and for what purpose. You can easily revoke or rotate keys on a per-server basis without affecting the other server.

<b>Flexibility</b>: If you ever need to change the key or restrict access, having separate keys makes it easier to manage these changes without interrupting access between servers.

___
## Time Synchronization

`timedatectl`is used 
```
[root@centos8 log]# timedatectl
               Local time: Mi 2024-08-14 14:47:18 UTC
           Universal time: Mi 2024-08-14 14:47:18 UTC
                 RTC time: Mi 2024-08-14 14:47:18
                Time zone: UTC (UTC, +0000)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

`timedatectl list-timezones` will give you a list of the timezones and you can set it with :
`timedatectl set-timezone Europe/Berlin`

Chronyd config is stored here :
 `/etc/chrony.conf`

DON'T USE NTP AND CHRONYD. CHRONYD HAS SUPERCEEDED IT !

 you can check the chrony sync using `chronyc`
```
chronyc> sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* 79.133.44.142                 1   9   377    84    +37us[  +55us] +/-  654us
^- ntp1.kashra-server.com        2   7   377     7   +148us[ +148us] +/-   16ms
^- ntp.fra1.de.leaseweb.net      2   8   377   139  +3018us[+3036us] +/-   91ms
^- vps01.i87b.de                 2   9   377    18   +294us[ +294us] +/-   30ms
```


___
## Manage Linux Networking
* `yum install bind-utils` to install nslookup etc.
* `yum install net-tools` to install netstat etc.

### NetworkManager

#### Important files:
* <b>directory</b>: `/etc/sysconfig/network-scripts`
```
[root@centos2 network-scripts]# cat ifcfg-eth0
# Created by cloud-init on instance boot automatically, do not edit.
#
AUTOCONNECT_PRIORITY=120
BOOTPROTO=none                      <-- static       
DEFROUTE=yes
DEVICE=eth0
GATEWAY=64.226.80.1
HWADDR=12:f6:3a:f7:fe:2e
IPADDR=64.226.83.19
IPADDR1=10.19.0.5
MTU=1500
NETMASK=255.255.240.0
NETMASK1=255.255.0.0
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
```
* <b>file</b>: /etc/hosts
* <b>file</b>: /etc/hostname
* <b>file</b>: /etc/resolv.conf -> list of dns servers
* <b>file</b>: /etc/nsswitch.conf -> how to resolve names, first files then dns etc.

#### nmcli
`nmcli` (Network Manager Command Line Interface):
* `nmcli` is a command-line tool used to interact with NetworkManager and manage network settings, such as configuring and controlling network interfaces, setting up network connections (e.g., Ethernet, Wi-Fi), and viewing network status.

```
nmcli connection modify 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03 ipv4.addresses 64.226.76.183/24
nmcli connection modify 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03 ipv4.gateway 192.168.1.1
nmcli connection modify 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03 ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection modify 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03 ipv4.method manual
nmcli connection reload
```


#### nmtui
`nmtui` (Network Manager Text User Interface):
* `nmtui` provides a text-based user interface for managing network settings, allowing users to configure network connections using a menu-driven interface in the terminal.
Usage Scenarios: Useful for users who prefer a semi-graphical interface or are working in a non-GUI environment, such as a server, and need a more user-friendly tool than nmcli to configure networks.



#### nm-connection-editor
`nm-connection-editor`:
* `nm-connection-editor` is a graphical tool used to create, edit, and manage network connections. It provides a GUI interface for configuring all types of network connections, including wired, wireless, VPN, and more.



#### Important commands
##### ping

##### ifconfig / ip 


##### ifup / ifdown
-> interface up / interface down

#### netstat
```
[root@centos1 ~]# netstat -rnv
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         164.90.176.1    0.0.0.0         UG        0 0          0 eth0
10.19.0.0       0.0.0.0         255.255.0.0     U         0 0          0 eth0
10.114.0.0      0.0.0.0         255.255.240.0   U         0 0          0 eth1
164.90.176.0    0.0.0.0         255.255.240.0   U         0 0          0 eth0
```


##### traceroute


##### tcpdump
```
[root@centos1 sshd_config.d]# tcpdump -i eth0
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
06:41:49.711264 IP centos1.ssh > xdsl-188-154-47-102.adslplus.ch.50406: Flags [P.], seq 2949716432:2949716492, ack 3838753987, win 1002, options [nop,nop,TS val 1355438850 ecr 1729410591], length 60
06:41:49.711317 IP centos1.ssh > xdsl-188-154-47-102.adslplus.ch.50406: Flags [P.], seq 60:96, ack 1, win 1002, options [nop,nop,TS val 1355438850 ecr 1729410591], length 36
06:41:49.711513 IP centos1.ssh > xdsl-188-154-47-102.adslplus.ch.50406: Flags [P.], seq 96:204, ack 1, win 1002, options [nop,nop,TS val 1355438850 ecr 1729410591], length 108
```
##### nslookup / dig

##### ethtool
```
# ethtool eth0
Settings for eth0:
	Supported ports: [  ]
	Supported link modes:   Not reported
	Supported pause frame use: No
	Supports auto-negotiation: No
	Supported FEC modes: Not reported
	Advertised link modes:  Not reported
	Advertised pause frame use: No
```
___
## FTP (vsftpd - server proc)

### Server installation
```
# yum install vsftpd
DigitalOcean Droplet Agent                                                                                                                                                                         33 kB/s | 3.3 kB     00:00
Dependencies resolved.
==================================================================================================================================================================================================================================
 Package                                             Architecture                                        Version                                                     Repository                                              Size
==================================================================================================================================================================================================================================
Installing:
 vsftpd                                              x86_64                                              3.0.5-5.el9                                                 appstream                                              168 k
 ```

 ### configure
 `/etc/vsftpd/vsftpd.conf`


## Client side FTP 
```
# yum install ftp
DigitalOcean Droplet Agent                                                                                                                                                                         56 kB/s | 3.3 kB     00:00
Dependencies resolved.
==================================================================================================================================================================================================================================
 Package                                           Architecture                                         Version                                                     Repository                                               Size
==================================================================================================================================================================================================================================
Installing:
 ftp                                               x86_64                                               0.17-89.el9                                                 appstream                                                62 k

```


```
[aryan@centos1 ~]$ ftp centos2
Connected to centos2 (64.226.83.19).
220 (vsFTPd 3.0.5)
Name (centos2:aryan):
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> hash
Hash mark printing on (1024 bytes/hash mark).
ftp> put file.txt
local: file.txt remote: file.txt
227 Entering Passive Mode (64,226,83,19,24,117).
150 Ok to send data.
#
226 Transfer complete.
10 bytes sent in 6.5e-05 secs (153.85 Kbytes/sec)
ftp> bye
221 Goodbye.
```
___

## Package Manager

### Repos
`/etc/yum.repos.d/*`

### Erase / Remove packages
#### Using rpm -e
NOTE: Problem with this is will not remove dependancies!!!
```
$ rpm -qa |grep -i bind-utils
bind-utils-9.16.23-15.el9.x86_64
$ rpm -e bind-utils-9.16.23-15.el9.x86_64         <-- this will remove th pkg
$ rpm -qa |grep -i bind-utils
$
```


#### Using yum
```
[root@centos1 ~]# yum remove bind-utils
Dependencies resolved.
==================================================================================================================================================================================================================================
 Package                                                Architecture                                     Version                                                       Repository                                            Size
==================================================================================================================================================================================================================================
Removing:
 bind-utils                                             x86_64                                           32:9.16.23-15.el9                                             @appstream                                           644 k
Removing unused dependencies:
 bind-libs                                              x86_64                                           32:9.16.23-15.el9                                             @appstream                                           3.5 M
 bind-license                                           noarch                                           32:9.16.23-15.el9                                             @appstream                                            18 k
 fstrm                                                  x86_64                                           0.6.1-3.el9                                                   @appstream                                            55 k
 libuv                                                  x86_64                                           1:1.42.0-2.el9                                                @appstream                                           396 k
 protobuf-c                                             x86_64                                           1.3.3-13.el9                                                  @baseos                                               62 k

Transaction Summary
==================================================================================================================================================================================================================================
Remove  6 Packages

Freed space: 4.6 M
Is this ok [y/N]: y
```

### downloading and installing packages

Use `wget` to get the rpm and install using `rpm -hiv zsh-5.8-7.el9.x86_64.rpm`
```
[root@centos1 ~]# wget https://rpmfind.net/linux/centos-stream/9-stream/BaseOS/x86_64/os/Packages/zsh-5.8-7.el9.x86_64.rpm
--2024-08-15 08:49:26--  https://rpmfind.net/linux/centos-stream/9-stream/BaseOS/x86_64/os/Packages/zsh-5.8-7.el9.x86_64.rpm
Resolving rpmfind.net (rpmfind.net)... 195.220.108.108
Connecting to rpmfind.net (rpmfind.net)|195.220.108.108|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3398329 (3.2M) [application/x-rpm]
Saving to: ‘zsh-5.8-7.el9.x86_64.rpm’

zsh-5.8-7.el9.x86_64.rpm                                 100%[==================================================================================================================================>]   3.24M  6.81MB/s    in 0.5s

2024-08-15 08:49:27 (6.81 MB/s) - ‘zsh-5.8-7.el9.x86_64.rpm’ saved [3398329/3398329]


[root@centos1 ~]# rpm -hiv zsh-5.8-7.el9.x86_64.rpm
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:zsh-5.8-7.el9                    ################################# [100%]
[root@centos1 ~]#
```

### downloading and installing packages
Use `rpm -qi` to query pkg information

```
[root@centos1 ~]# rpm -qi zsh-5.8-7.el9.x86_64.rpm
Name        : zsh
Version     : 5.8
Release     : 7.el9
Architecture: x86_64
Install Date: (not installed)
Group       : Unspecified
Size        : 8020813
License     : MIT
Signature   : RSA/SHA256, Fri 13 Aug 2021 06:12:56 PM UTC, Key ID 05b555b38483c65d
Source RPM  : zsh-5.8-7.el9.src.rpm
Build Date  : Tue 10 Aug 2021 06:14:26 AM UTC
Build Host  : x86-06.stream.rdu2.redhat.com
Packager    : builder@centos.org
Vendor      : CentOS
URL         : http://zsh.sourceforge.net/
Summary     : Powerful interactive shell
Description :
The zsh shell is a command interpreter usable as an interactive login
shell and as a shell script command processor.  Zsh resembles the ksh
shell (the Korn shell), but includes many enhancements.  Zsh supports
command line editing, built-in spelling correction, programmable
command completion, shell functions (with autoloading), a history
mechanism, and more.
```

### List config files for package
Here you can use `rpm -qc <PKG>`

```
[root@centos1 ~]# rpm -qc zsh-5.8-7.el9.x86_64.rpm
/etc/skel/.zshrc
/etc/zlogin
/etc/zlogout
/etc/zprofile
/etc/zshenv
/etc/zshrc
```

### List config file for package
Use `rpm -qf <FULL PATH TO FILE>` to find out which package a file belongs to.

```
[root@centos1 ~]# which nmcli
/usr/bin/nmcli
[root@centos1 ~]# rpm -qf /usr/bin/nmcli
NetworkManager-1.43.9-1.el9.x86_64
[root@centos1 ~]#
```

### Redhat Verisoning

Updates vs Upgrades:

* `yum update -y` : deletes packages and auto confirms. Same as `yum upgrade -y`


### Make a local repo
copy the repo souce to `/root/localrepo` for example
```
yum install createrepo_c
vi /etc/yum.repos.d/local.repo  <-create this file
________ 
[zshRepo]
name=zshRepo
baseurl=file:///root/localrepo/
enabled=1
gpgcheck=0
_________

createrepo /root/local_repo/
yum clean all
yum repolist all

# test
yum install zsh
```

## Server Dump and support
you can run the following :
`sos report`

It will end like this:
```

Your sosreport has been generated and saved in:
	/var/tmp/sosreport-centos1-2024-08-15-zbasnzo.tar.xz

 Size	16.38MiB
 Owner	root
 sha256	2ef58e3498492d4c05ec72f3f515411d8382cac309d0bc6c0848429843cfbd6a

Please send this file to your support representative.
````

### Cockpit - web based interface for servers
```
# yum install cockpit
CentOS Stream 9 - BaseOS                                                                                                                                                                                                                                                  13 MB/s | 8.2 MB     00:00
CentOS Stream 9 - AppStream                                                                                                                                                                                                                                               28 MB/s |  20 MB     00:00
CentOS Stream 9 - Extras packages                                                                                                                                                                                                                                         41 kB/s |  18 kB     00:00
DigitalOcean Droplet Agent                                                                                                                                                                                                                                               6.8 kB/s | 3.3 kB     00:00
Dependencies resolved.
=========================================================================================================================================================================================================================================================================================================
 Package                                                                        Architecture                                                       Version                                                                   Repository                                                             Size
=========================================================================================================================================================================================================================================================================================================
Installing:
 cockpit                                                                        x86_64                                                             321-1.el9                                                                 baseos                                                                 42 k
Installing dependencies:
 python3-psutil                                                                 x86_64                                                             5.8.0-12.el9                                                              appstream                                                             214 k
 tracer-common                                                                  noarch                                                             1.1-2.el9                                                                 appstream                                                              23 k
Installing weak dependencies:
 cockpit-packagekit                                                             noarch                                                             321-1.el9                                                                 appstream                                                             789 k
 python3-tracer                                                                 noarch                                                             1.1-2.el9                                                                 appstream                                                             154 k

Transaction Summary
=========================================================================================================================================================================================================================================================================================================
Install  5 Packages
```

`systemctl start cockpit`

You can access it with `https://123.123.123.123:9090`


___
# RH134

## Shells

### What is my shell?:
```
[root@centos1 log]# echo $0
-bash
````
### What shells are installed?:
```
[root@centos1 log]# cat /etc/shells
/bin/sh
/bin/bash
/usr/bin/sh
/usr/bin/bash
/usr/bin/zsh
/bin/zsh
````
___

## Tuning
### tuned and tuned-adm
* `tuned-adm list` lists the list of profiles available:

```
[root@centos1 ~]# tuned-adm list
Cannot talk to TuneD daemon via DBus. Is TuneD daemon running?
Available profiles:
- accelerator-performance     - Throughput performance based tuning with disabled higher latency STOP states
- aws                         - Optimize for aws ec2 instances
- balanced                    - General non-specialized tuned profile
- desktop                     - Optimize for the desktop use-case
- hpc-compute                 - Optimize for HPC compute workloads
- intel-sst                   - Configure for Intel Speed Select Base Frequency
- latency-performance         - Optimize for deterministic performance at the cost of increased power consumption
- network-latency             - Optimize for deterministic performance at the cost of increased power consumption, focused on low latency network performance
- network-throughput          - Optimize for streaming network throughput, generally only necessary on older CPUs or 40G+ networks
- optimize-serial-console     - Optimize for serial console use.
- powersave                   - Optimize for low power consumption
- throughput-performance      - Broadly applicable tuning that provides excellent performance across a variety of common server workloads
- virtual-guest               - Optimize for running inside a virtual guest
- virtual-host                - Optimize for running KVM guests
No current active profile.

````

* `tuned-adm active` will list what profile is currently active.
```
[root@centos1 ~]# tuned-adm active
Current active profile: virtual-guest
```
___

* `tuned-adm profile <profileName>` switch profiles

```
[root@centos1 ~]# tuned-adm profile balanced
[root@centos1 ~]# tuned-adm active
Current active profile: balanced
```
___
* `tuned-adm recommend` redhat will recommend a profile
```
[root@centos1 ~]# tuned-adm recommend
virtual-guest
```
___
* `tuned-adm off` redhat will recommend a profile
```
[root@centos1 ~]# tuned-adm off
[root@centos1 ~]# tuned-adm active
No current active profile.
```
___
Profile can be swtiched using cockpit https://x.x.x.x:9090
___


### nice and renice
1 CPU means computation of 1 process a time. FIFO

* Nice Values:

`-20` Higest priority

`19`  Lowest priority

* The Kernal also sets priority, this cannot be changed:

(0 to 99) real time space

(100 to 139) for user space

* To see the nice values from the ps command:

`ps axo pid,comm,nice,cls --sort=-nice`

* You can start a process with a nice value with `nice`

`nice -n <niceVal> <proc name>`

* and you can amend a nice value with `renice`

`renice -n 19 16250`

___

## ACL's
setfacl - set file access control lists
getfacl - view file access control lists

|command|result|
|--------|------|
|`setfacl -m u:user:rwx /path/to/file`| add permission for a single user|
|`setfacl -x u:user /path/to/file`| remove permission for a single user|
|`setfacl -b /path/to/file`| remove permission for all users|
|`setfacl -m g:group:rw /path/to/file`| add permission for a group|
|`setfacl -Rm "entry" /path/to/file`| to allow all files and dirs to inherit ACL of parent dir|

IMPORTANT:
* `rwxrwxrwx+` signifies ACL's are applied
* setting `w` permission with ACL does <b>NOT</b> allow to remove the file

### Examples

```
[root@centos1 tmp]# getfacl readme.md
# file: readme.md
# owner: root
# group: root
user::rw-
user:aryan:rw-
group::r--
mask::rw-
other::r--

[root@centos1 tmp]# ls -l  readme.md
-rw-rw-r--+ 1 root root 5 Aug 16 09:11 readme.md
[root@centos1 tmp]#
```


___
## SELinux (Security Enhanced Linux)
Linux kernel security module for supporting access control security policies and mandatory access rights. The project is by NSA and SELinux community.


Normal Linux uses DAC(<b>D</b>iscretionary <b>A</b>ccess <b>C</b>ontrol) 
* DAC: Owners control access to their resources using `chmod` and `setfacl`

SELinux uses MAC (<b>M</b>andatory <b>A</b>ccess <b>C</b>ontrol)
*  A central authority enforces strict access policies.
*  Access to resources is controlled by a central authority through predefined policies. These policies dictate what actions users can perform on resources, regardless of the resource owner's wishes.
* The access control decisions in MAC are based on labels and policies that are predefined by the system administrators. These labels are associated with files, processes, and users, and the system enforces these policies strictly.

### 3 ways to run SELinux
|Type              | Meaning                    | Setting     | 
|------------------|----------------------------|-------------|
|<b>Enforcing</b>  | Enabled(_default_)         | setenforce 1|
|<b>Permissive</b> | Disabled but logs activity | setenforce 0|


### get status
```
[root@centos1 tmp]# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33

[root@centos1 tmp]# getenforce
Enforcing
```

### set status 
This will remain in effect until a restart occurs.
```
[root@centos1 tmp]# getenforce
Enforcing

[root@centos1 tmp]# setenforce 0
[root@centos1 tmp]# getenforce
Permissive

[root@centos1 tmp]# setenforce 1
[root@centos1 tmp]# getenforce
Enforcing

```

### Config 
This will be permanant (incl. after restart)
1. Edit the file: `/etc/selinux/config`:
```
SELINUX=enforcing
SELINUX=disabled
```

2.  `touch /.autorelabel`


### 2 Main conepts of SELinux
Example every file/dir has USER and TYPE example

[root@centos1 tmp]# ls -lZ /usr/sbin/httpd

-rwxr-xr-x. 1 root root `system_u`:`object_r`:`httpd_exec_t`:`s0` 585912 Feb 14  2024 /usr/sbin/httpd

| SELinux       | Description |
|---------------|-------------|
|`system_u`     | This is the SELinux user, not to be confused with the traditional Linux user.    |
|`object_r`     | This is the SELinux role. In most cases, files and directories are labeled with object_r, indicating they are objects (i.e., files, directories, etc.). The role is more relevant for processes and their execution contexts. |
|`httpd_exec_t` | This is the SELinux type. In SELinux, types are used to enforce policies. The httpd_exec_t type indicates that this file is an executable that can be executed by the httpd (Apache) service. SELinux policies define what domains or processes (like the Apache web server) can execute files labeled with this type. |
|`s0`           | This is the SELinux level (sensitivity label). The level can be used to enforce Multi-Level Security (MLS) policies. s0 typically represents the default sensitivity level, indicating that no special MLS policies apply to this file.

When you start a process SELinux will start the proc with the type lable. for example:
```
[root@centos1 ~]# systemctl status httpd
○ httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; preset: disabled)
     Active: inactive (dead)
       Docs: man:httpd.service(8)
[root@centos1 ~]# systemctl start httpd

[root@centos1 ~]# ps auxwwwZ | grep -i httpd_t
system_u:system_r:httpd_t:s0    root       31659  0.2  2.4  21076 11300 ?        Ss   07:07   0:00 /usr/sbin/httpd -DFOREGROUND
system_u:system_r:httpd_t:s0    apache     31660  0.0  1.5  22952  7120 ?        S    07:07   0:00 /usr/sbin/httpd -DFOREGROUND
system_u:system_r:httpd_t:s0    apache     31661  0.0  1.9 982372  8932 ?        Sl   07:07   0:00 /usr/sbin/httpd -DFOREGROUND
system_u:system_r:httpd_t:s0    apache     31662  0.0  2.0 982372  9700 ?        Sl   07:07   0:00 /usr/sbin/httpd -DFOREGROUND
system_u:system_r:httpd_t:s0    apache     31663  0.0  1.9 1113508 9188 ?        Sl   07:07   0:00 /usr/sbin/httpd -DFOREGROUND
```

Label is also assigned at the socket level:
```
[root@centos1 ~]# netstat -anZ |grep -i httpd_t
tcp6       0      0 :::80                   :::*                    LISTEN      31659/httpd          system_u:system_r:httpd_t:s0
unix  2      [ ACC ]     STREAM     LISTENING     484783   31660/httpd          system_u:system_r:httpd_t:s0                       /etc/httpd/run/cgisock.31659
unix  2      [ ]         DGRAM                    484781   31659/httpd          system_u:system_r:httpd_t:s0
unix  3      [ ]         STREAM     CONNECTED     484726   31659/httpd          system_u:system_r:httpd_t:s0
```

### Managing SELinux
#### Get config
Get a list of the boolean values that are currently set:
```
[root@centos1 ~]# getsebool -a |more
abrt_anon_write --> off
abrt_handle_event --> off
abrt_upload_watch_anon_write --> on
antivirus_can_scan_system --> off
antivirus_use_jit --> off
auditadm_exec_content --> on
authlogin_nsswitch_use_ldap --> off
authlogin_radius --> off
authlogin_yubikey --> off
awstats_purge_apache_log_files --> off
boinc_execmem --> on
cdrecord_read_content --> off
cluster_can_network_connect --> off
cluster_manage_all_files --> off
cluster_use_execmem --> off
...
```

#### Set config
```
[root@centos2 ~]# getsebool -a |grep httpd_can_connect_ftp
httpd_can_connect_ftp --> on
[root@centos2 ~]# setsebool -P httpd_can_connect_ftp off
[root@centos2 ~]# getsebool -a |grep httpd_can_connect_ftp
httpd_can_connect_ftp --> off
```

#### Set a label
```
[root@centos1 ~]# ls -lrtZ aiden.sh
-rw-r--r--. 1 root root unconfined_u:object_r:admin_home_t:s0 0 Aug 17 07:17 aiden.sh

[root@centos1 ~]#  chcon -t httpd_user_script_exec_t aiden.sh

[root@centos1 ~]# ls -lrtZ aiden.sh
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_user_script_exec_t:s0 0 Aug 17 07:17 aiden.sh

```


___
## Storage
### Adding a Volume
#### 1) Attach a HDD
I added a new volume and this is the additional output of `fdisk -l`
```
Disk /dev/sda: 2 GiB, 2147483648 bytes, 4194304 sectors
Disk model: Volume
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

#### 2) Create a partition
```
[root@centos1 ~]# fdisk /dev/sda
...
   n   add a new partition
...
Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-4194303, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-4194303, default 4194303):

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): w                                       <-write
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.


```

#### 3) format the Filesystem
```
[root@centos1 ~]# mkfs.xfs /dev/sda1
meta-data=/dev/sda1              isize=512    agcount=4, agsize=131008 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0
data     =                       bsize=4096   blocks=524032, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=16384, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
Discarding blocks...Done.
```


#### 4) mount the volume
```
[root@centos1 ~]# mkdir /data
[root@centos1 ~]# mount /dev/sda1 /data
[root@centos1 ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        4.0M     0  4.0M   0% /dev
tmpfs           229M     0  229M   0% /dev/shm
tmpfs            92M  2.4M   89M   3% /run
/dev/vda1        10G  1.5G  8.5G  15% /
tmpfs            46M     0   46M   0% /run/user/0
/dev/sda1       2.0G   47M  1.9G   3% /data
```


#### 5) Update `/etc/fstab` to persist
```
[root@centos1 ~]# vi /etc/fstab
---ADD THIS:
/dev/sda1	/data	xfs defaults	0	0
```
___

## LVM
LVM's allow physical disks to be combined together into a logical volume or Volume group and that volumen group can then see seen as a single volume which can be partitioned.



* Disk 1 `---->`rootvg
___
* Disk 2`\`................... `/---->` /data1

* Disk 3 `---->`datavg `----------->` /data2

* Disk 4`/`....................`\---->` /data3

* ...................................`\---->` /data4
___




The heirarchy from bottom to top, in how LVM's are configured
<table>
  <tr>
    <td style="text-align: center;">6) FILE SYSTEM</td>
    <td colspan="3" style="text-align: center;">data_fs</td>
  </tr>
  <tr>
    <td style="text-align: center;">5) LOGICAL VOLUME</td>
    <td colspan="3" style="text-align: center;">data_lv</td>
  </tr>
  <tr>
    <td style="text-align: center;">4) VOLUME GROUP</td>
    <td colspan="3" style="text-align: center;">data_vg</td>
  </tr>
  <tr>
    <td style="text-align: center;">3) PHYSICAL VOLUME</td>
    <td>/dev/sda1</td>
    <td>/dev/sdb1</td>
    <td>/dev/sdc1</td>
  </tr>
  <tr>
    <td style="text-align: center;">2) PARTITIONS</td>
    <td>/dev/sda1</td>
    <td>/dev/sdb1</td>
    <td>/dev/sdc1</td>
  </tr>
  <tr>
    <td style="text-align: center;">1) HARD DISKS</td>
    <td>/dev/sda</td>
    <td>/dev/sdb</td>
    <td>/dev/sdc</td>
  </tr>
</table>


### Creating an LVM
#### 1) Attach a HDD

```
[root@centos2 ~]# fdisk -l
...
Disk /dev/sda: 1 GiB, 1073741824 bytes, 2097152 sectors
Disk model: Volume
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

#### 2) Create a Partition
```
[root@centos2 ~]# fdisk /dev/sda

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)

Select (default p): p
Partition number (1-4, default 1):
First sector (2048-2097151, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-2097151, default 2097151):

Created a new partition 1 of type 'Linux' and of size 1023 MiB.

Command (m for help): p
Disk /dev/sda: 1 GiB, 1073741824 bytes, 2097152 sectors
Disk model: Volume
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x40a33b22

Device     Boot Start     End Sectors  Size Id Type
/dev/sda1        2048 2097151 2095104 1023M 83 Linux       <--WE MUST CHNG ID TO LVM

Command (m for help): t
Selected partition 1
Hex code or alias (type L to list all): L

00 Empty            24 NEC DOS          81 Minix / old Lin  bf Solaris
01 FAT12            27 Hidden NTFS Win  82 Linux swap / So  c1 DRDOS/sec (FAT-
02 XENIX root       39 Plan 9           83 Linux            c4 DRDOS/sec (FAT-
03 XENIX usr        3c PartitionMagic   84 OS/2 hidden or   c6 DRDOS/sec (FAT-
04 FAT16 <32M       40 Venix 80286      85 Linux extended   c7 Syrinx
05 Extended         41 PPC PReP Boot    86 NTFS volume set  da Non-FS data
06 FAT16            42 SFS              87 NTFS volume set  db CP/M / CTOS / .
07 HPFS/NTFS/exFAT  4d QNX4.x           88 Linux plaintext  de Dell Utility
08 AIX              4e QNX4.x 2nd part  8e Linux LVM        df BootIt
09 AIX bootable     4f QNX4.x 3rd part  93 Amoeba           e1 DOS access
0a OS/2 Boot Manag  50 OnTrack DM       94 Amoeba BBT       e3 DOS R/O
0b W95 FAT32        51 OnTrack DM6 Aux  9f BSD/OS           e4 SpeedStor
0c W95 FAT32 (LBA)  52 CP/M             a0 IBM Thinkpad hi  ea Linux extended
0e W95 FAT16 (LBA)  53 OnTrack DM6 Aux  a5 FreeBSD          eb BeOS fs
0f W95 Ext'd (LBA)  54 OnTrackDM6       a6 OpenBSD          ee GPT
10 OPUS             55 EZ-Drive         a7 NeXTSTEP         ef EFI (FAT-12/16/
11 Hidden FAT12     56 Golden Bow       a8 Darwin UFS       f0 Linux/PA-RISC b
12 Compaq diagnost  5c Priam Edisk      a9 NetBSD           f1 SpeedStor
14 Hidden FAT16 <3  61 SpeedStor        ab Darwin boot      f4 SpeedStor
16 Hidden FAT16     63 GNU HURD or Sys  af HFS / HFS+       f2 DOS secondary
17 Hidden HPFS/NTF  64 Novell Netware   b7 BSDI fs          fb VMware VMFS
18 AST SmartSleep   65 Novell Netware   b8 BSDI swap        fc VMware VMKCORE
1b Hidden W95 FAT3  70 DiskSecure Mult  bb Boot Wizard hid  fd Linux raid auto
1c Hidden W95 FAT3  75 PC/IX            bc Acronis FAT32 L  fe LANstep
1e Hidden W95 FAT1  80 Old Minix        be Solaris boot     ff BBT

Aliases:
   linux          - 83
   swap           - 82
   extended       - 05
   uefi           - EF
   raid           - FD
   lvm            - 8E
   linuxex        - 85
Hex code or alias (type L to list all): 8e                <-CHANGE TO LVM
Changed type of partition 'Linux' to 'Linux LVM'.

Command (m for help): p
Disk /dev/sda: 1 GiB, 1073741824 bytes, 2097152 sectors
Disk model: Volume
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x40a33b22

Device     Boot Start     End Sectors  Size Id Type
/dev/sda1        2048 2097151 2095104 1023M 8e Linux LVM

Command (m for help): w                                  <-WRITE TO TABLE
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

#### 3) Create a Physical Volume
```
[root@centos2 ~]# pvcreate  /dev/sda1
  Physical volume "/dev/sda1" successfully created.
  Creating devices file /etc/lvm/devices/system.devices

[root@centos2 ~]# pvdisplay
  "/dev/sda1" is a new physical volume of "1023.00 MiB"
  --- NEW Physical volume ---
  PV Name               /dev/sda1
  VG Name
  PV Size               1023.00 MiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               s2UPPt-jd6W-Qw6t-bgIn-BRY0-OL5C-XP9ecX
```

#### 3) Create a volume Group(VG)
```
[root@centos2 ~]# vgcreate data_vg /dev/sda1
  Volume group "data_vg" successfully created

[root@centos2 ~]# vgdisplay data_vg
  --- Volume group ---
  VG Name               data_vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               1020.00 MiB
  PE Size               4.00 MiB
  Total PE              255
  Alloc PE / Size       0 / 0
  Free  PE / Size       255 / 1020.00 MiB
  VG UUID               VSo1VA-2H9U-tyq4-7DdQ-sa12-Cv6e-0EAcRw
```


#### 4) Create a logical Volum(LV)
```
[root@centos2 ~]# lvcreate -n data_lv --size 1000MB data_vg
  Logical volume "data_lv" created.

[root@centos2 ~]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/data_vg/data_lv
  LV Name                data_lv
  VG Name                data_vg
  LV UUID                Vhgy5K-bDFT-4XkQ-Wg2Q-UvTm-DhaG-1xa98l
  LV Write Access        read/write
  LV Creation host, time centos2, 2024-08-17 10:05:16 +0000
  LV Status              available
  # open                 0
  LV Size                1000.00 MiB
  Current LE             250
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0
```

#### 5) Format the disk
```
[root@centos2 ~]# mkfs.xfs /dev/data_vg/data_lv
meta-data=/dev/data_vg/data_lv   isize=512    agcount=4, agsize=64000 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0
data     =                       bsize=4096   blocks=256000, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=16384, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
Discarding blocks...Done.
[root@centos2 ~]#
```

#### 6) Mount the LV
```
[root@centos2 ~]# mkdir /data
[root@centos2 ~]# mount /dev/data_vg/data_lv /data
[root@centos2 ~]# df -h
Filesystem                   Size  Used Avail Use% Mounted on
devtmpfs                     4.0M     0  4.0M   0% /dev
tmpfs                        231M     0  231M   0% /dev/shm
tmpfs                         93M   12M   81M  13% /run
/dev/vda1                     10G  1.3G  8.8G  13% /
tmpfs                         47M     0   47M   0% /run/user/0
/dev/mapper/data_vg-data_lv  936M   39M  898M   5% /data          <-- Mounted!
```

## Extending LVM's
I have filled up the disk with `dd``
```
[root@centos2 data]# df -h /data
Filesystem                   Size  Used Avail Use% Mounted on
/dev/mapper/data_vg-data_lv  936M  936M  212K 100% /data
```

### Creating an LVM
#### 1) Attach a HDD

```
[root@centos2 ~]# fdisk -l
...
Disk /dev/sdb: 2 GiB, 2147483648 bytes, 4194304 sectors
Disk model: Volume
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

#### 2) Create a Partition
```
[root@centos2 ~]# fdisk /dev/sdb
Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-4194303, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-4194303, default 4194303):

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): p
Disk /dev/sdb: 2 GiB, 2147483648 bytes, 4194304 sectors
Disk model: Volume
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x3c029d8a

Device     Boot Start     End Sectors Size Id Type
/dev/sdb1        2048 4194303 4192256   2G 83 Linux

Command (m for help): t
Selected partition 1
Hex code or alias (type L to list all): 8e
Changed type of partition 'Linux' to 'Linux LVM'.

Command (m for help): p
Disk /dev/sdb: 2 GiB, 2147483648 bytes, 4194304 sectors
Disk model: Volume
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x3c029d8a

Device     Boot Start     End Sectors Size Id Type
/dev/sdb1        2048 4194303 4192256   2G 8e Linux LVM

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

#### 3) Create a Physical Volume
```
[root@centos2 ~]# pvcreate  /dev/sdb1
  Physical volume "/dev/sda1" successfully created.
  Creating devices file /etc/lvm/devices/system.devices

[root@centos2 ~]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sdc1
  VG Name               data_vg
  PV Size               1023.00 MiB / not usable 3.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              255
  Free PE               5
  Allocated PE          250
  PV UUID               s2UPPt-jd6W-Qw6t-bgIn-BRY0-OL5C-XP9ecX

  "/dev/sdb1" is a new physical volume of "<2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1
  VG Name
  PV Size               <2.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               8dQIGc-s6S0-HVGr-7dFE-TueP-rWNx-71819A
  ```

#### 3) Extend the volume Group(VG)
```
[root@centos2 ~]# vgextend data_vg /dev/sdb1
  Volume group "data_vg" successfully extended

[root@centos2 ~]# vgdisplay
  --- Volume group ---
  VG Name               data_vg
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               2.99 GiB                      <-- INCREASED SIZE
  PE Size               4.00 MiB
  Total PE              766
  Alloc PE / Size       250 / 1000.00 MiB
  Free  PE / Size       516 / <2.02 GiB
  VG UUID               VSo1VA-2H9U-tyq4-7DdQ-sa12-Cv6e-0EAcRw

```


#### 4) Extend the logical Volum(LV)
```
[root@centos2 ~]# lvextend -L+2GB /dev/mapper/data_vg-data_lv
  Size of logical volume data_vg/data_lv changed from 1000.00 MiB (250 extents) to <2.98 GiB (762 extents).
  Logical volume data_vg/data_lv successfully resized.

[root@centos2 ~]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/data_vg/data_lv
  LV Name                data_lv
  VG Name                data_vg
  LV UUID                Vhgy5K-bDFT-4XkQ-Wg2Q-UvTm-DhaG-1xa98l
  LV Write Access        read/write
  LV Creation host, time centos2, 2024-08-17 10:05:16 +0000
  LV Status              available
  # open                 0
  LV Size                <2.98 GiB                            <--INCREASED SIZE
  Current LE             762
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

```

#### 5) Extend the Filesystem
```
[root@centos2 data]# xfs_growfs /dev/mapper/data_vg-data_lv
meta-data=/dev/mapper/data_vg-data_lv isize=512    agcount=4, agsize=64000 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0
data     =                       bsize=4096   blocks=256000, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=16384, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 256000 to 780288

[root@centos2 data]# df -h
Filesystem                   Size  Used Avail Use% Mounted on
devtmpfs                     4.0M     0  4.0M   0% /dev
tmpfs                        231M     0  231M   0% /dev/shm
tmpfs                         93M  2.4M   90M   3% /run
/dev/vda1                     10G  1.3G  8.8G  13% /
tmpfs                         47M     0   47M   0% /run/user/0
/dev/mapper/data_vg-data_lv  3.0G  951M  2.0G  32% /data
```

##  Stratis (advanced storage management)

### Install 
`yum install stratis-cli stratisd`

### Start 
`systemctl start stratisd`
`systemctl status stratisd`

### Add 2x 5GB volumes:
`fdisk -l` shows:
```
Disk /dev/sdd: 5 GiB, 5368709120 bytes, 10485760 sectors
Disk model: Volume
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sde: 5 GiB, 5368709120 bytes, 10485760 sectors
Disk model: Volume
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

### Create a Pool
```
[root@centos2 data]# stratis pool create pool1 /dev/sdd

[root@centos2 data]# stratis pool list
Name           Total / Used / Free    Properties                                   UUID   Alerts
pool1   5 GiB / 526 MiB / 4.49 GiB   ~Ca,~Cr, Op   8a4e4e1c-aff5-4a77-9e8e-03967aedc381   WS001
```

### Extend Pool
```
[root@centos2 data]# stratis pool add-data pool1 /dev/sde

[root@centos2 data]# stratis pool list
Name            Total / Used / Free    Properties                                   UUID   Alerts
pool1   10 GiB / 532 MiB / 9.48 GiB   ~Ca,~Cr, Op   8a4e4e1c-aff5-4a77-9e8e-03967aedc381
```

### To see actual size
<b>Thin Provisioning</b>: Stratis uses thin provisioning, which means it can allocate storage space flexibly without actually reserving physical space upfront. When you create a Stratis filesystem, it allows the filesystem to grow dynamically up to the size of the underlying pool.

<b>Virtual Capacity</b>: Stratis does not pre-allocate the full storage space when creating filesystems. Instead, it presents a "virtual" capacity to the operating system and only consumes physical space as data is written to the filesystem. This virtual capacity can be much larger than the actual physical storage you initially allocated.
You will notice that the size will be listed as 1TB. 

You can use tools like `stratis pool list` to get the actual size and `stratis filesystem list` to see the actual usage:

```
[root@centos2 ~]# df -h
Filesystem                                                                                       Size  Used Avail Use% Mounted on
...
/dev/mapper/stratis-1-8a4e4e1caff54a779e8e03967aedc381-thin-fs-9cfb0211425841be9843008ecdaf7555  1.0T  7.2G 1017G   1% /bigdata

[root@centos2 ~]# stratis pool list
Name             Total / Used / Free    Properties                                   UUID   Alerts
pool1   10 GiB / 1.05 GiB / 8.95 GiB   ~Ca,~Cr, Op   8a4e4e1c-aff5-4a77-9e8e-03967aedc381   WS001

[root@centos2 ~]# stratis filesystem list
Pool    Filesystem    Total / Used / Free / Limit            Created             Device                           UUID
pool1   datastorefs   1 TiB / 546 MiB / 1023.47 GiB / None   Aug 17 2024 11:07   /dev/stratis/pool1/datastorefs   9cfb0211-4258-41be-9843-008ecdaf7555
```

<b>Metadata and Overheads</b>: The difference between the 1.05 GiB used at the pool level and the 546 MiB used at the filesystem level can be attributed to the metadata and other overheads managed by Stratis. The pool usage (1.05 GiB) includes all overheads related to managing the pool and filesystems, which is why it reports a higher usage compared to the filesystem (546 MiB), which only reflects the actual data stored.

<b>Thin Provisioning Impact</b>: Since Stratis uses thin provisioning, the filesystem reports a large potential capacity (1 TiB), but it only occupies a small amount of space (546 MiB) because that's all the actual data stored. The pool's usage reflects all allocated blocks, including metadata.

### FS snapshot
A Stratis snapshot is a point-in-time, read-only copy of a Stratis filesystem that captures the state of the filesystem at a specific moment. Snapshots are useful for preserving data before making changes that might be risky or for creating backups that can be quickly reverted to if needed.
```
[root@centos2 ~]# stratis filesystem snapshot pool1 datastorefs datastorefs-snap

[root@centos2 ~]# stratis filesystem list
Pool    Filesystem         Total / Used / Free / Limit            Created             Device                                UUID
pool1   datastorefs        1 TiB / 546 MiB / 1023.47 GiB / None   Aug 17 2024 11:07   /dev/stratis/pool1/datastorefs        9cfb0211-4258-41be-9843-008ecdaf7555
pool1   datastorefs-snap   1 TiB / 546 MiB / 1023.47 GiB / None   Aug 19 2024 06:08   /dev/stratis/pool1/datastorefs-snap   f8f45b16-9f00-46ec-9b35-bf162160ad23
```
### Mounting a Stratis Filesystem
`vi /etc/fstab`

```
# Stratis FS
UUID=9cfb0211-4258-41be-9843-008ecdaf7555 /bigdata      xfs defaults,x-systemd.requires=stratisd.service   0 0
UUID=f8f45b16-9f00-46ec-9b35-bf162160ad23 /bigdataSnap  xfs defaults,x-systemd.requires=stratisd.service   0 0
```

___

## NFS (Network File System)

### Server Side setup and config
```
yum install nfs-utils libnfsidmap
systemctl enable rpcbind
systemctl enable nfs-server

systemctl start rpcbind
systemctl start rpc-statd
systemctl start nfs-server
systemctl start nfs-idmapd

mkdir /deltaforce
chmod 777 /deltaforce

vi /etc/exports
...
#share      allowIP     #Perm,sync write,root on client=root on server   
/deltaforce 192.168.12.7(rw,sync,no_root_squash)       <- IMPORTANT : NO SPACES
...

exportfs -rv
```


### Client side connection

```
[root@centos1 ~]# yum install nfs-utils rpcbind
Last metadata expiration check: 0:00:24 ago on Mon 19 Aug 2024 07:29:58 AM UTC.
Package nfs-utils-1:2.5.4-26.el9.x86_64 is already installed.
Package rpcbind-1.2.6-7.el9.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!

[root@centos1 ~]# systemctl start rpcbind

[root@centos1 ~]# mkdir /mnt/app

[root@centos1 ~]# mount centos2:/deltaforce /mnt/app

[root@centos1 ~]# ls -lrt /mnt/app
total 0
-rw-r--r--. 1 root root 0 Aug 19 07:33 server.file

[root@centos1 ~]# df -k
Filesystem                 1K-blocks    Used Available Use% Mounted on
...
centos2:/deltaforce         10417152 1318272   9098880  13% /mnt/app
```
___

## SAMBA / CIFS (mounting non linux FS's)

* Sambra shares its FS though SMB (Server Message Block protocol)
* CIFS (Common Internet File System) became an extension of SMB and have become synonymous with one another.


• Install samba packages

`yum install samba samba-client samba-common`


• Enable samba to be allowed through firewall (Only if you have firewall running)
```
firewall-cmd --permanent --zone=public --add-service=samba
firewall-cmd –reload
```
• Create Samba share directory and assign permissions
```
mkdir -p /samba/morepretzels
chmod a+rwx /samba/morepretzels
chown -R nobody:nobody /samba
```

• Also, you need to change the SELinux security context for the samba shared
directory as follows: (Only if you have SELinux enabled)

`chcon -t samba_share_t /samba/morepretzels``


* Modify /etc/samba/smb.conf file to add new shared filesystem (Make sure to
create a copy of smb.conf file)
Delete everything from smb.conf file and add the following parameters
```
[global]
workgroup = WORKGROUP
netbios name = centos
security = user
map to guest = bad user
dns proxy = no

[Anonymous]
path = /samba/morepretzels
browsable = yes
writable = yes
guest ok = yes
guest only = yes
read only = no
```

• Verify the setting
`testparm`

• Once the packages are installed, enable and start Samba services
```
systemctl enable smb
systemctl enable nmb
systemctl start smb
systemctl start nmb
```

* Mount on Linux client
```
yum -y install cifs-utils samba-client
mkdir /mnt/sambashare
Mount the samba share
mount -t cifs //192.168.1.95/Anonymous /mnt/sambashare/
```

## Secure Samba

• Create a group smbgrp & user larry to access the samba server with proper authentication
```
useradd larry
groupadd smbgrp
usermod -a -G smbgrp larry
smbpasswd -a larry
New SMB password: YOUR SAMBA PASS
Retype new SMB password: REPEAT YOUR SAMBA PASS
Added user larry
```

• Create a new share, set the permission on the share:
```
mkdir /samba/securepretzels
chown -R larry:smbgrp /samba/securepretzels
chmod -R 0770 /samba/securepretzels
chcon -t samba_share_t /samba/securepretzels
```

• Edit the configuration file /etc/samba/smb.conf (Create a backup copy first)
```
vi /etc/samba/smb.conf
   <Add the following lines>

[Secure]
path = /samba/securepretzels
valid users = @smbgrp
guest ok = no
writable = yes
browsable = yes
```

• Restart the services
```
systemctl restart smb
systemctl restart nmb
```
___


## Boot Process
|Step1|Step2|Step3|Step4|Step5|Step6|
|-|-|-|-|-|-|
|BIOS||||||
|->|POST|||||
|->|->|MBR||||
|->|->|->|GRUB|||
|->|->|->|->|Kernal||
|->|->|->|->|->|systemd|

## Systemd Targets
* systemd is the 1st linux process (id 1)
* run levels = targets
* most common, market with `*`

| Target                | Description                                                                                   |
|-----------------------|-----------------------------------------------------------------------------------------------|
| `default.target`      | The default target the system boots into, typically a symbolic link to `graphical.target` or `multi-user.target`. |
| `* graphical.target`    | A full multi-user mode with a graphical user interface (GUI). Includes everything in `multi-user.target` plus a display manager. |
| `* multi-user.target`   | Multi-user, non-graphical environment, similar to traditional runlevel 3. Networking is enabled, but no GUI is started. |
| `* rescue.target`       | Single-user mode with basic system functionality. Only essential services are started, providing a root shell for maintenance. |
| `* emergency.target`    | Minimal environment providing only a root shell without any services or daemons running, used for emergency maintenance. |
| `reboot.target`       | Shuts down the system and reboots it.                                                          |
| `shutdown.target`     | Shuts down the system without rebooting.                                                       |
| `poweroff.target`     | Powers off the system completely.                                                              |
| `halt.target`         | Halts the system without powering off the machine.                                             |
| `suspend.target`      | Puts the system into suspend mode, a low-power state where the system can be quickly resumed.  |
| `hibernate.target`    | Puts the system into hibernation, saving the state to disk and powering off the system.        |
| `hybrid-sleep.target` | Puts the system into both suspend and hibernate modes, suspending to RAM and writing the state to disk. |
| `runlevel1.target`    | Backward compatibility target, maps to `rescue.target`.                                        |
| `runlevel3.target`    | Backward compatibility target, maps to `multi-user.target`.                                    |
| `runlevel5.target`    | Backward compatibility target, maps to `graphical.target`.                                     |
| `sysinit.target`      | Responsible for early system initialization, including mounting filesystems and starting kernel modules. |
| `basic.target`        | Minimal system state that includes basic services like logging and system messaging, required by most higher-level targets. |
| `network.target`      | Indicates that networking should be configured and active. Services that require networking depend on this target. |

### Check current target 
```
[root@centos1 ~]# systemctl get-default
multi-user.target

```

### Targets can have dependancies
```
[root@centos1 ~]# systemctl list-dependencies graphical.target|grep -i target
graphical.target
● └─multi-user.target
●   ├─basic.target
●   │ ├─paths.target
●   │ ├─slices.target
●   │ ├─sockets.target
●   │ ├─sysinit.target
●   │ │ ├─cryptsetup.target
●   │ │ ├─integritysetup.target
●   │ │ ├─local-fs.target
●   │ │ ├─swap.target
●   │ │ └─veritysetup.target
●   │ └─timers.target
●   ├─cloud-init.target
●   ├─getty.target
●   ├─nfs-client.target
●   │ └─remote-fs-pre.target
●   └─remote-fs.target
●     └─nfs-client.target
●       └─remote-fs-pre.target
```

### Display which runlevel is linked to which targets
```
[root@centos1 ~]# ls -l /lib/systemd/system/runlevel*
lrwxrwxrwx. 1 root root 15 Jun 19 11:35 /lib/systemd/system/runlevel0.target -> poweroff.target
lrwxrwxrwx. 1 root root 13 Jun 19 11:35 /lib/systemd/system/runlevel1.target -> rescue.target
lrwxrwxrwx. 1 root root 17 Jun 19 11:35 /lib/systemd/system/runlevel2.target -> multi-user.target
lrwxrwxrwx. 1 root root 17 Jun 19 11:35 /lib/systemd/system/runlevel3.target -> multi-user.target
lrwxrwxrwx. 1 root root 17 Jun 19 11:35 /lib/systemd/system/runlevel4.target -> multi-user.target
lrwxrwxrwx. 1 root root 16 Jun 19 11:35 /lib/systemd/system/runlevel5.target -> graphical.target
lrwxrwxrwx. 1 root root 13 Jun 19 11:35 /lib/systemd/system/runlevel6.target -> reboot.target
```

### Change default target

```
[root@centos1 ~]# systemctl set-default graphical.target
Removed "/etc/systemd/system/default.target".
Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/graphical.target.

[root@centos1 ~]# systemctl get-default
graphical.target

[root@centos1 ~]# systemctl set-default multi-user.target
Removed "/etc/systemd/system/default.target".
Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/multi-user.target.
[root@centos1 ~]# systemctl status multi-user.target
● multi-user.target - Multi-User System
     Loaded: loaded (/usr/lib/systemd/system/multi-user.target; indirect; preset: disabled)
     Active: active since Sat 2024-08-17 08:40:16 UTC; 2 days ago
      Until: Sat 2024-08-17 08:40:16 UTC; 2 days ago
       Docs: man:systemd.special(7)

[root@centos1 ~]# systemctl get-default
multi-user.target
```
___
## Recover Root Password

* go to the console and reboot the server

`reboot`

* push `up` `down` to make the GRUB menu active. You will see your OS and a rescue version of your OS.

* select the OS and hit `e` to edit 

* Find the line starting with linux or linux16.
example:

`linux /vmlinuz-3.10.0-1127.el7.x86_64 root=/dev/mapper/rhel-root ro crashkernel=auto rhgb quiet`

CHANGE TO THIS:
`linux /vmlinuz-3.10.0-1127.el7.x86_64 root=/dev/mapper/rhel-root rw init=/sysroot/bin/sh crashkernel=auto rhgb quiet`

* hit CTRL X -This will start in single user mode

```
chroot /sysroot
passwd root
touch /.autorelabel
exit
reboot
```

___
## Repair file system corruption
* Common types of corruption

 Problem |Result|
|-|-|
|Corrupt file system|systemd attempts to repair the fs. If the problem is too severe for auto fix, the system drops the user to emergency shell|
|Nonexistant device or UUID referenced in `/etc/fstab`|systemd waits for a set amount of time, waiting for the device to become avail. If the device does not become avail, the system drops the user to an emergency shell after the t/o
|Nonexistant mount point in `/etc/fstab`|The system drops into emergency shell|
|incorrect mount option in `/etc/fstab`|The system drops into emergency shell|

___

## Firewalld

- - <b>Tables</b>: Collections of rules organized by their purpose (filtering, NAT, etc.).
- - <b>Chains</b>: Ordered sets of rules within tables that process packets at different stages.
- - <b>Rules</b>: Specific conditions and actions defined for how packets should be handled.
- - <b>Targets</b>: The actions taken when a packet matches a rule (e.g., ACCEPT, REJECT, DROP).

### Install
```
yum install firewalld -y
systemctl enable firewalld
systemctl start firewalld
systemctl status firewalld
```

#
```
[root@centos2 deltaforce]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

### Get predifined services that can be referenced to enable / disable
```
[root@centos2 deltaforce]# firewall-cmd --get-services
RH-Satellite-6 RH-Satellite-6-capsule afp amanda-client amanda-k5-client amqp amqps apcupsd audit ausweisapp2 bacula bacula-client bareos-director bareos-filedaemon bareos-storage bb bgp bitcoin bitcoin-rpc bitcoin-testnet bitcoin-testnet-rpc bittorrent-lsd ceph ceph-exporter ceph-mon cfengine checkmk-agent cockpit collectd condor-collector cratedb ctdb dds dds-multicast dds-unicast dhcp dhcpv6 dhcpv6-client distcc dns dns-over-tls docker-registry docker-swarm dropbox-lansync elasticsearch etcd-client etcd-server finger foreman foreman-proxy freeipa-4 freeipa-ldap freeipa-ldaps freeipa-replication freeipa-trust ftp galera ganglia-client ganglia-master git gpsd grafana gre high-availability http http3 https ident imap imaps ipfs ipp ipp-client ipsec irc ircs iscsi-target isns jenkins kadmin kdeconnect kerberos kibana klogin kpasswd kprop kshell kube-api kube-apiserver kube-control-plane kube-control-plane-secure kube-controller-manager kube-controller-manager-secure kube-nodeport-services kube-scheduler kube-scheduler-secure kube-worker kubelet kubelet-readonly kubelet-worker ldap ldaps libvirt libvirt-tls lightning-network llmnr llmnr-client llmnr-tcp llmnr-udp managesieve matrix mdns memcache minidlna mongodb mosh mountd mqtt mqtt-tls ms-wbt mssql murmur mysql nbd nebula netbios-ns netdata-dashboard nfs nfs3 nmea-0183 nrpe ntp nut openvpn ovirt-imageio ovirt-storageconsole ovirt-vmconsole plex pmcd pmproxy pmwebapi pmwebapis pop3 pop3s postgresql privoxy prometheus prometheus-node-exporter proxy-dhcp ps2link ps3netsrv ptp pulseaudio puppetmaster quassel radius rdp redis redis-sentinel rpc-bind rquotad rsh rsyncd rtsp salt-master samba samba-client samba-dc sane sip sips slp smtp smtp-submission smtps snmp snmptls snmptls-trap snmptrap spideroak-lansync spotify-sync squid ssdp ssh steam-streaming svdrp svn syncthing syncthing-gui syncthing-relay synergy syslog syslog-tls telnet tentacle tftp tile38 tinc tor-socks transmission-client upnp-client vdsm vnc-server warpinator wbem-http wbem-https wireguard ws-discovery ws-discovery-client ws-discovery-tcp ws-discovery-udp wsman wsmans xdmcp xmpp-bosh xmpp-client xmpp-local xmpp-server zabbix-agent zabbix-server zerotier
```

### Get Zones and rules
```
[root@centos2 deltaforce]# firewall-cmd --get-zones
block dmz drop external home internal nm-shared public trusted work

[root@centos2 deltaforce]# firewall-cmd --get-active-zones
public
  interfaces: eth0 eth1

[root@centos2 deltaforce]# firewall-cmd --get-active-zones
public
  interfaces: eth0 eth1
[root@centos2 deltaforce]# firewall-cmd --zone=public --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

### Add a service temporarily
```
[root@centos-s-1vcpu-512mb-10gb-fra1-01 ~]# firewall-cmd --add-service=http
success

[root@centos-s-1vcpu-512mb-10gb-fra1-01 ~]# firewall-cmd --add-service=http
success
[root@centos-s-1vcpu-512mb-10gb-fra1-01 ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources:
  services: cockpit dhcpv6-client http ssh          <-- http was added
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
if you reload it will flush out the temporary rules. Example:
```
[root@centos-s-1vcpu-512mb-10gb-fra1-01 ~]# firewall-cmd --reload
success

[root@centos-s-1vcpu-512mb-10gb-fra1-01 ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
___
### Add a service Permanantly
```
[root@centos-s-1vcpu-512mb-10gb-fra1-01 ~]# firewall-cmd --add-service=http --permanent
success
```
___
### Add 3rd Party Service
Here we will create a custom service.

Service definition location : 

`cd /usr/lib/firewalld/services`

Copy an existing service and make a copy.


`cp ssh.xml appsrv.xml`

-> update the xml
```
[root@centos]# vi appsrv.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>AppSrv</short>
  <description>This is a 3rd Party application service</description>
  <port protocol="tcp" port="3720"/>
</service>
```

Restart firewalld
```
systemctl restart firewalld
```

add the Service
```
[root@centos-s-1vcpu-512mb-10gb-fra1-01 services]# firewall-cmd --add-service=appsrv --permanent
success
[root@centos-s-1vcpu-512mb-10gb-fra1-01 services]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources:
  services: appsrv cockpit dhcpv6-client http ssh          <--- appsrv is now active
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
  ```

___
### Add a Port

```
[root@centos-s-1vcpu-512mb-10gb-fra1-01 services]# firewall-cmd --add-port 1110/tcp --permanent
success

[root@centos-s-1vcpu-512mb-10gb-fra1-01 services]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources:
  services: cockpit dhcpv6-client http ssh
  ports: 1110/tcp                     <- port is added
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

___
### Regect incomming connection from an IP 

```
[root@centos-s-1vcpu-512mb-10gb-fra1-01 services]# firewall-cmd --add-rich-rule='rule family="ipv4" source address="192.168.0.25" reject'
success
[root@centos-s-1vcpu-512mb-10gb-fra1-01 services]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources:
  services: cockpit dhcpv6-client http ssh
  ports: 1110/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
	rule family="ipv4" source address="192.168.0.25" reject              <-Rich rule added
  ```

### Regect incomming connection ping traffic

```
[root@centos-s-1vcpu-512mb-10gb-fra1-01 services]# firewall-cmd --add-icmp-block-inversion
success
[root@centos-s-1vcpu-512mb-10gb-fra1-01 services]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: yes           <--- block icmp
  interfaces: eth0 eth1
  sources:
  services: cockpit dhcpv6-client http ssh
  ports: 1110/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
	rule family="ipv4" source address="192.168.0.25" reject
```

### DROP outgoing traffic to a specific IP
```

[root@centos-s-1vcpu-512mb-10gb-fra1-01 services]# ping 157.240.0.35
PING 157.240.0.35 (157.240.0.35) 56(84) bytes of data.
64 bytes from 157.240.0.35: icmp_seq=1 ttl=55 time=1.76 ms
64 bytes from 157.240.0.35: icmp_seq=2 ttl=55 time=0.836 ms
--- 157.240.0.35 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.836/1.299/1.763/0.463 ms

[root@centos]# firewall-cmd --direct --add-rule ipv4 filter OUTPUT 0 -d 157.240.0.35 -j DROP
success

[root@centos]# ping 157.240.0.35
PING 157.240.0.35 (157.240.0.35) 56(84) bytes of data.
--- 157.240.0.35 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3069ms

```

## Containers (podman)

