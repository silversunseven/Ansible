
# Notes for learning ansible

- [Distribute key to managed hosts ](#distribute-key-to-managed-hosts)
- [Get the version of Ansilbe](#get-version-of-ansible)
- [Anisible Config file Priority heirarchy](#anisible-config-file-priority-heirarchy)
- [Inventories](#inventories)
- [Modules](#modules)
- [Ansible Documentation](#ansible-documentation)
- [YAML](#yaml)
- [Playbooks](#playbooks)

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
ubuntu-c ansible_connection=local                       # no ssh is need for this connection.
centos1 ansible_user=root ansible_port=2222             # will run as user root, hitting port 2222
centos1:2222 ansible_user=root                          # will run as user root, hitting port 2222 (alternate method)
centos2 ansible_user=root
centos3 ansible_user=root

[ubuntu]
ubuntu1 ansible_become=true ansible_become_pass=password    # will run as current user but will become root
ubuntu2 ansible_become=true ansible_user=root
ubuntu3 ansible_become=true ansible_user=root
```

Inventories can also be simplified using ranges and group with group vars:
```
[control]
ubuntu-c ansible_connection=local

[centos]
centos[1:3]

[centos:vars]
ansible_user=root

[ubuntu]
ubuntu[1:3]

[ubuntu:vars]
ansible_become=true
ansible_become_pass=password

[linux:children]
centos
ubuntu

[all:vars]
ansible_port=22
```

### Commands
| Command                                      | Explanation                                          |
|----------------------------------------------|------------------------------------------------------|
| ansible centos -m ping                       | centos here is the group based on the inventory, using module ping |
| ansible centos -m ping -o                    | centos here is the group based on the inventory, using module ping. OneLine version |
| ansible "centos*" -m ping                    | Wildcards can be used but must be quoted|
| ansible centos --list-hosts                  | will list the hosts in the centos group|
| ansible ~.*3 -m ping                         | tilda is the start of a REGEX pattern |
| ansible all -m command -a "id" -o            | uses module commmand with -a argument |
| ansible all -a id -o                         | same as above - the default module is commmand |
| ansible linux -m ping -e 'ansible_port=2222' -o| -e is for overiding EXTRA_VARS. These override any vars previously setS |

Ansible uses colours to show the state:
<p style="color:red;">Failure in red</p>
<p style="color:green;">Success in green</p>
<p style="color:yellow;">Changed in yellow</p>

This Inventory file can be written as an ini, yaml or json. For exmaple:

#### hosts.ini:
```
[control]
ubuntu-c ansible_connection=local

[centos]
centos1 ansible_port=2222
centos[2:3]

[centos:vars]
ansible_user=root

[ubuntu]
ubuntu[1:3]

[ubuntu:vars]
ansible_become=true
ansible_become_pass=password

[linux:children]
centos
ubuntu
```

#### hosts.yaml:
```
---
control:
  hosts:
    ubuntu-c:
      ansible_connection: local
centos:
  hosts:
    centos1:
      ansible_port: 2222
    centos2:
    centos3:
  vars:
    ansible_user: root
ubuntu:
  hosts:
    ubuntu1:
    ubuntu2:
    ubuntu3:
  vars:
    ansible_become: true
    ansible_become_pass: password
linux:
  children:
    centos:
    ubuntu:
...
```
#### hosts.json:

```
{
    "control": {
        "hosts": {
            "ubuntu-c": {
                "ansible_connection": "local"
            }
        }
    },
    "centos": {
        "hosts": {
            "centos1": {
                "ansible_port": 2222
            },
            "centos2": null,
            "centos3": null
        },
        "vars": {
            "ansible_user": "root"
        }
    },
    "ubuntu": {
        "hosts": {
            "ubuntu1": null,
            "ubuntu2": null,
            "ubuntu3": null
        },
        "vars": {
            "ansible_become": true,
            "ansible_become_pass": "password"
        }
    },
    "linux": {
        "children": {
            "centos": null,
            "ubuntu": null
        }
    }
}
```

## Modules

### Setup Module
ansible.builtin.setup (Now a Builtin plugin)

https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html

This is automaticallly executed when using playbooks to gather useful information as variables from targets, these are called Facts.

Can also be executed directly by the anosble command module to find all the variables it creates. 

```
ansible@ubuntu-c:~$ ansible -i,centos1 all -m setup|more
centos1 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "172.18.0.8"
        ],
        "ansible_all_ipv6_addresses": [],
        "ansible_apparmor": {
            "status": "disabled"
        },
        "ansible_architecture": "aarch64",
        "ansible_bios_date": "NA",
        "ansible_bios_vendor": "NA",
        ...
````

### File Module
ansible.builtin.file (Now a Builtin plugin)

https://docs.ansible.com/ansible/latest/collections/ansible/builtin/setup_module.html

Sets atributes of files, symlinks and directories.

on windows you can use the `win_file`module

```
$ ansible all -m file -a "path
=/var/tmp/test state=touch" 
ubuntu-c | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": true,
    "dest": "/var/tmp/test",
    "gid": 1000,
    "group": "ansible",
    "mode": "0664",
    "owner": "ansible",
    "size": 0,
    "state": "file",
    "uid": 1000
}
centos2 | CHANGED => {
    "ansible_facts": {
```
Setting the permission of a file

```
$ ansible all -m file -a "path=/var/tmp/test state=file mode=600" 
ubuntu-c | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "gid": 1000,
    "group": "ansible",
    "mode": "0600",
    "owner": "ansible",
    "path": "/var/tmp/test",
    "size": 0,
    "state": "file",
    "uid": 1000
}
centos2 | SUCCESS => {
```
### Copy Module
ansible.builtin.copy (Now a Builtin plugin)

https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
 
 Copies a file from local/remote to a remote location.

`ansible.builtin.copy`  : local/remote  -> remote

`ansible.builtin.fetch`  : remote -> Local

`win_copy`for windows

It uses checksums to verify by default.
` "checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709",`


```
$ touch /tmp/x
$ ansible all -m copy -a 'src=/tmp/x dest=/tmp/x'
ubuntu-c | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
    "dest": "/tmp/x",
    "gid": 1000,
    "group": "ansible",
    "mode": "0664",
    "owner": "ansible",
    "path": "/tmp/x",
    "size": 0,
    "state": "file",
    "uid": 1000
}
centos3 | CHANGED => {
  ...
````
You can also rename a remote file with this module using the flag `remote_src=yes`

```
$ ansible all -m copy -a 'remote_src=yes src=/tmp/x dest=/tmp/y'
ubuntu-c | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": true,
    "checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
    "dest": "/tmp/y",
    "gid": 1000,
    "group": "ansible",
    "md5sum": "d41d8cd98f00b204e9800998ecf8427e",
    "mode": "0664",
    "owner": "ansible",
    "size": 0,
    "src": "/tmp/x",
    "state": "file",
    "uid": 1000
}
...
```


### fetch Module Example

```
$ ansible all -m fetch -a 'dest=result src=/tmp/test_modules.txt'
ubuntu-c | CHANGED => {
    "changed": true,
    "checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
    "dest": "/home/ansible/diveintoansible/Ansible Architecture and Design/Modules/result/ubuntu-c/tmp/test_modules.txt",
    "md5sum": "d41d8cd98f00b204e9800998ecf8427e",
    "remote_checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
    "remote_md5sum": null
}
centos1 | CHANGED => {
```
It creates the following Structure :
```
result
├── centos1
│   └── tmp
│       └── test_modules.txt
├── centos2
│   └── tmp
│       └── test_modules.txt
├── centos3
│   └── tmp
│       └── test_modules.txt
├── ubuntu-c
│   └── tmp
│       └── test_modules.txt
├── ubuntu1
│   └── tmp
│       └── test_modules.txt
├── ubuntu2
│   └── tmp
│       └── test_modules.txt
└── ubuntu3
    └── tmp
        └── test_modules.txt

14 directories, 7 files
```

### Command Module
ansible.builtin.command

https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html

Executes command on a set of hosts. It *doesn't* use a shell  so `$HOME` and operators like `<,>,|,&,;` will not work, if you need that use the `shell` module.

For Windows use `win_command`


## Ansible Documentation

You can find it all online but even better is that it exists on the command line. Example:

```ansible-doc fetch
> ANSIBLE.BUILTIN.FETCH    (/usr/local/lib/python3.10/dist-packages/ansible/modules/fetch.py)

        This module works like [ansible.builtin.copy], but in reverse. It is used for fetching files from remote machines and
        storing them locally in a file tree, organized by hostname. Files that already exist at `dest' will be overwritten if
        they are different than the `src'. This module is also supported for Windows targets.

ADDED IN: version 0.2 of ansible-core

  * note: This module has a corresponding action plugin.

OPTIONS (= is mandatory):

= dest
        A directory to save the file into.
        For example, if the `dest' directory is `/backup' a `src' file named `/etc/profile' on host `host.example.com', would
        be saved into `/backup/host.example.com/etc/profile'. The host name is based on the inventory name.

- fail_on_missing
        When set to `true', the task will fail if the remote file cannot be read for any reason.
        Prior to Ansible 2.5, setting this would only fail if the source file was missing.
        The default was changed to `true' in Ansible 2.5.
        default: true
        type: bool
        added in: version 1.1 of ansible-core
...
```

## YAML
Important notes to remember!

### <u>!- Single quote are litteral quotes, whereas double quotes are interpreted.</u>
### <u>!- Multilines and single lines:</u>
* * This is interpreted as a single line because of the `|` 
```
---
exmaple_key_1: |
  this is a string
  that goes over
  multiple lines
...
```
in python this is:
```
{'exmaple_key_1': 'this is a string\nthat goes over\nmultiple lines\n'}
```
___
* * This is interpreted as a single line in python and ansible because of the `>` 

```
---
exmaple_key_1: >
  this is a string
  that goes over
  multiple lines
...
```
in python this is:
```
{'exmaple_key_1': 'this is a string that goes over multiple lines\n'}

```
___
note: the `>` added the `\n`at the end. Yaml provides a way to mitigate this with `>-`
example:
```
---
exmaple_key_1: >-
  this is a string
  that goes over
  multiple lines
...
````
in python this is:
```
{'exmaple_key_1': 'this is a string that goes over multiple lines'}
```
___
### <u>!- Integers are automatically intepreted as INT unless quoted.</u>
* Any of these can represent Boolean true or false in Ansible:  

| Boolean | result | comment |
|---------|--------|---------|
|false|false||
|False|false||
|FALSE|false||
|no|false||
|No|false||
|NO|false||
|off|false||
|Off|false||
|OFF|false||
|n|false|in ansible this works, but python it doesn't|
|||
|||
|true|true||
|True|true||
|TRUE|true||
|yes|true||
|Yes|true||
|YES|true||
|onf|true||
|On|true||
|ON|true||
|y|true|in ansible this works, but python it doesn't|

It is recommended to use `False` or `True`
___
### <u>!- Lists `[]` are assigned with `-`</u> an these actually create a python list.
```
---
- item 1
- item 2
- item 3
- item 4
- item 5
...
```

You can also show a list like this in tha YML file:

`[example_list_entry_1, example_list_entry_2]`

### <u>!- Dictionaries `{}` are assigned with  key `:` value  </u> an these actually create a python dictionary.
___
```
---
example_key_1 : example_value_1
example_key_2 : example_value_2
...
```

You can also show a dictionary like this in tha YML file:

`{'example_key_1': 'example_value_1', 'example_key_2': 'example_value_2'}`
___

### <u>!- Indentation </u>
YML uses a 2 Character indentation.

In this example have a dictionary and each key has a `dictionary` as a value:

```
---
example_key_1:
  sub_example_key1: sub_example:value1

example_key_2:
  sub_example_key2: sub_example:value2
...
````

in Python:

```
{'example_key_1': {'sub_example_key1': 'sub_example_value1'},
 'example_key_2': {'sub_example_key2': 'sub_example_value2'}}
 ```
___

In this example have a dcitionary and each key has a `list` as a value:
```
---
example_1: 
  - item_1
  - item_2
  - item_3

example_2: 
  - item_4
  - item_5
  - item_6
...
```

in Python:

```
{'example_1': ['item_1', 'item_2', 'item_3'],
 'example_2': ['item_4', 'item_5', 'item_6']}
```
___

In this example have a dcitionary and each key has a dictionary as a value which contains a list.
```
---
example_dictionary_1:
  - example_dictionary_2:
    - 1
    - 2
    - 3
  - example_dictionary_3:
    - 4
    - 5
    - 6
  - example_dictionary_4:
    - 7
    - 8
    - 9
...
```

in Python:

```
{'example_dictionary_1': [{'example_dictionary_2': [1, 2, 3]},
                          {'example_dictionary_3': [4, 5, 6]},
                          {'example_dictionary_4': [7, 8, 9]}]}
```

### Useful Links:
https://en.wikipedia.org/wiki/YAML#History_and_name

https://yaml.org/spec/
___

## Playbooks
### Structure
```
# YAML documents begin with the document separator ---

# The minus in YAML this indicates a list item.  The playbook contains a list 
# of plays, with each play being a dictionary
-

  # Hosts: where our play will run and options it will run with

  # Vars: variables that will apply to the play, on all target systems

  # Tasks: the list of tasks that will be executed within the play, this section
  #       can also be used for pre and post tasks

  # Handlers: the list of handlers that are executed as a notify key from a task

  # Roles: list of roles to be imported into the play

# Three dots indicate the end of a YAML document
...
```

### Some important notes:

-> `gather_facts: False` will not run the setup module.

-> `"{{ var_name }}"` is a Jinja2 variable used by the jinja2 templating system.

-> Handlers use the notify key inside a task. the execute once after there has been a change. `notify:`and `when:` will call the `handler`matching the `notify` name. 

-> aHere we gather facts so we can get the `ansible_distribution` variable.
ß
```
---
# YAML documents begin with the document separator ---
 
# The minus in YAML this indicates a list item.  The playbook contains a list

# of plays, with each play being a dictionary
 
  # Hosts: where our play will run and options it will run with
  hosts: linux
 
  # Vars: variables that will apply to the play, on all target systems
  vars:
    motd_centos: "Welcome to CentOS Linux - Ansible Rocks\n"
    motd_ubuntu: "Welcome to Ubuntu Linux - Ansible Rocks\n"
 
  # Tasks: the list of tasks that will be executed within the playbook
  tasks:
    - name: Configure a MOTD (message of the day)
      copy:
        content: "{{ motd_centos }}"
        dest: /etc/motd
      notify: MOTD changed
      when: ansible_distribution == "CentOS"

    - name: Configure a MOTD (message of the day)
      copy:
        content: "{{ motd_ubuntu }}"
        dest: /etc/motd
      notify: MOTD changed
      when: ansible_distribution == "Ubuntu"
 
  # Handlers: the list of handlers that are executed as a notify key from a task
  handlers:
    - name: MOTD changed
      debug:
        msg: The MOTD was changed
 
  # Roles: list of roles to be imported into the play
 
# Three dots indicate the end of a YAML document
...
```