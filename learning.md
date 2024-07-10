
# Notes for learning ansible
## Distribute Key to managed hosts
```
ansible@ubuntu-c:~$ echo password > password.txt

ansible@ubuntu-c:~$ for user in ansible root
do
  for os in ubuntu centos
  do
    for instance in 1 2 3
    do
      sshpass -f password.txt ssh-copy-id -o StrictHostKeyChecking=no ${user}@${os}${instance}
    done
  done
done

ansible -i,ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3 all -m ping
```
## Get version of ansible
```
$ ansible --version
ansible [core 2.16.6]
  config file = /home/ansible/testdir/ansible.cfg
  configured module search path = ['/home/ansible/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.10/dist-packages/ansible
  ansible collection location = /home/ansible/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.10.12 (main, Nov 20 2023, 15:14:05) [GCC 11.4.0] (/usr/bin/python3)
  jinja version = 3.1.3
  libyaml = True

$ pip freeze|grep ansible
ansible==9.5.1
ansible-core==2.16.6
````

## Anisible Config file Priority heirarchy
1. ${ANSIBLE_CONFIG} -> (Variable)
2. ./ansible.cfg    ->  (Current directory)
3. ~/.ansible.cfg   ->  (Home directory IMPORTANT: it must be .ansible.cfg)
4. /etc/ansible/ansible.cfg -> (/etc/ansible directory)

## Inventories 

### Config
ansible.cfg:
```
[defaults]
inventory = hosts               # inventory file (relative path)
host_key_checking = False       # Ignores fingerprinting
````

### inventory file
Host variable ansible_user has been set for elevated priv.
```
[centos]
centos1 ansible_user=root ansible_port=2222             # will run as user root, hitting port 2222
centos1:2222 ansible_user=root                          # will run as user root, hitting port 2222 (alternate method)
centos2 ansible_user=root
centos3 ansible_user=root

[ubuntu]
ubuntu1 ansible_become=true ansible_become_pass=password    # will run as current user but will become root
ubuntu2 ansible_become=true ansible_user=root
ubuntu3 ansible_become=true ansible_user=root
```

### Commands
| Command                                      | Explanation                                          |
|----------------------------------------------|------------------------------------------------------|
| ansible centos -m ping                       | centos here is the group based on the inventory, using module ping |
| ansible centos -m ping -o                    | centos here is the group based on the inventory, using module ping. Condensed version |
| ansible "centos*" -m ping                    | Wildcards can be used but must be quoted|
| ansible centos --list-hosts                  | will list the hosts in the centos group|
| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |

| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |
| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |
| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |
| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |
| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |
| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |
| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |
| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |
| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |

