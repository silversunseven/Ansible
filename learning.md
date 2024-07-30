
# Notes for learning ansible

- [Distribute key to managed hosts ](#distribute-key-to-managed-hosts)
- [Get the version of Ansilbe](#get-version-of-ansible)
- [Anisible Config file Priority heirarchy](#anisible-config-file-priority-heirarchy)
- [Inventories](#inventories)
- [Modules](#modules)
- [Ansible Documentation](#ansible-documentation)
- [YAML](#yaml)
- [Playbooks](#playbooks)
- [Variables](#variables)
- [Ansible Playbooks, facts](#ansible-playbooks-facts)

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
___

## Variables

### Different way to set and access variables:
Here i am using a combination of files to demonstrate different ways to set and access variables.

#### hosts (inventory file):
```
[control]
ubuntu-c ansible_connection=local

[centos]
centos1 ansible_port=22
centos[2:3] ARHostVar=monkey

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
mygroupvar=toes
```

#### external_vars.yaml (external variable file):
```
---
  XNumOfCats : 2

  Xnoofie:
    fur : grey
    legs : four
    eyes : hazel

  Xshopping_list:
    - milk
    - butter
    - cheese

  # Using the Inline method
  Xballs:
    {fur: white, legs: four, eyes: blue}

  Xnew_shopping_list:
    [ oatly, olives, feta]
...
````

#### variables_playbook.yaml (playbook):
```
---
# YAML documents begin with the document separator ---
 
# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
-
 
  # Hosts: where our play will run and options it will run with
  hosts: centos1, centos2
  gather_facts: True #needed to get hostvars

  # Var promting
  vars_prompt:
    - name: numOfFingers
      private: False 
    - name: secret
      private: True

  # Using an external file to source vars
  vars_files:
    - external_vars.yaml


  # Vars: variables that will apply to the play, on all target systems
  vars:
    NumOfCats : 2

    noofie:
      fur : grey
      legs : four
      eyes : hazel

    shopping_list:
      - milk
      - butter
      - cheese

    # Using the Inline method
    balls:
      {fur: white, legs: four, eyes: blue}

    new_shopping_list:
      [ oatly, olives, feta]



  # Tasks: the list of tasks that will be executed within the playbook
  tasks:
    - name: Test vars_prompt
      debug:
        msg: "You passed in {{ numOfFingers }} fingers"

    - name: Test vars_promt with private on
      debug:
        msg: "You passed in {{ secret }} as your secret"


    - name: Print NumOfCats var
      debug:
        msg: "{{ NumOfCats }}"

    - name: Print Full noofie dictionary
      debug:
        msg: "{{ noofie }}"
 
    - name: Print Value of eyes from noofie dictionary
      debug:
        msg: "{{ noofie.eyes }}"
 
    - name: Print Value of eyes from balls dictionary
      debug:
        msg: "{{ balls['eyes'] }}"

    - name: Print the 3rd item in the shoppinglist
      debug:
        msg: "{{ shopping_list[2] }}"

    - name: Print the 3rd item in the new_shoppinglist
      debug:
        msg: "{{ new_shopping_list[2] }}"

    - name: Print var from exrternal file source
      debug:
        msg: "{{ Xnew_shopping_list[2] }}"

    - name: Accesing a hostvars assigned by gathering facts
      debug:
        msg: "{{ hostvars[ansible_hostname].ansible_os_family }}"

    - name: Accessing hostvars, and if not exiting assign default
      debug:
        msg: "{{ hostvars[ansible_hostname].ARHostVar | default('none') }}"

    - name: Accessing groupvars
      debug:
        msg: "{{ hostvars[ansible_hostname].mygroupvar | default('none') }}"

# Three dots indicate the end of a YAML document
...
```

#### Output:
```
$ ansible-playbook variables_playbook.yaml 
numOfFingers: 10
secret: 

PLAY [centos1, centos2] **************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************************************
ok: [centos1]
ok: [centos2]

TASK [Test vars_prompt] **************************************************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": "You passed in 10 fingers"
}
ok: [centos2] => {
    "msg": "You passed in 10 fingers"
}

TASK [Test vars_promt with private on] ***********************************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": "You passed in SchneeScnhaSchnoofie as your secret"
}
ok: [centos2] => {
    "msg": "You passed in SchneeScnhaSchnoofie as your secret"
}

TASK [Print NumOfCats var] ***********************************************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": 2
}
ok: [centos2] => {
    "msg": 2
}

TASK [Print Full noofie dictionary] **************************************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": {
        "eyes": "hazel",
        "fur": "grey",
        "legs": "four"
    }
}
ok: [centos2] => {
    "msg": {
        "eyes": "hazel",
        "fur": "grey",
        "legs": "four"
    }
}

TASK [Print Value of eyes from noofie dictionary] ************************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": "hazel"
}
ok: [centos2] => {
    "msg": "hazel"
}

TASK [Print Value of eyes from balls dictionary] *************************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": "blue"
}
ok: [centos2] => {
    "msg": "blue"
}

TASK [Print the 3rd item in the shoppinglist] ****************************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": "cheese"
}
ok: [centos2] => {
    "msg": "cheese"
}

TASK [Print the 3rd item in the new_shoppinglist] ************************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": "feta"
}
ok: [centos2] => {
    "msg": "feta"
}

TASK [Print var from exrternal file source] ******************************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": "feta"
}
ok: [centos2] => {
    "msg": "feta"
}

TASK [Accesing a hostvars assigned by gathering facts] *******************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": "RedHat"
}
ok: [centos2] => {
    "msg": "RedHat"
}

TASK [Accessing hostvars, and if not exiting assign default] *************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": "none"
}
ok: [centos2] => {
    "msg": "monkey"
}

TASK [Accessing groupvars] ***********************************************************************************************************************************************************************************************
ok: [centos1] => {
    "msg": "toes"
}
ok: [centos2] => {
    "msg": "toes"
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************
centos1                    : ok=13   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
centos2                    : ok=13   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
````
___

### Passing in Extravars 
```
ansible-playbook variables_playbook.yaml -e DeleteData=True
```

### Vars as directory/files
You can also use this structure from where you inventory file is found to define host and group vars.
```
.
├── group_vars
│   ├── centos
│   └── ubuntu
├── host_vars
│   ├── centos1
│   └── ubuntu-c
├── hosts

```

## Ansible Playbooks, Facts
### Facts
https://docs.ansible.com/ansible/latest/collections/ansible/builtin/setup_module.html

You can use a filter(with wildcards) on the setup module to extract info, for example the command :

`ansible centos1 -m setup -a 'filter=ansible_mem*'`
```
$ ansible centos1 -m setup -a 'filter=ansible_mem*'
centos1 | SUCCESS => {
    "ansible_facts": {
        "ansible_memfree_mb": 3142,
        "ansible_memory_mb": {
            "nocache": {
                "free": 6257,
                "used": 1584
            },
            "real": {
                "free": 3142,
                "total": 7841,
                "used": 4699
            },
            "swap": {
                "cached": 0,
                "free": 1023,
                "total": 1023,
                "used": 0
            }
        },
        "ansible_memtotal_mb": 7841,
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": false
}
```
and to be more specific :
```
$ ansible centos1 -m setup -a 'filter=ansible_memfree_mb'
centos1 | SUCCESS => {
    "ansible_facts": {
        "ansible_memfree_mb": 3147,
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": false
}
````

! Important: Any module that returns a dictionary called `ansible_facts` will add the variables to the root of the `vars` namespace. To reference the var in ansible_facts, you do not need to use the key `ansible_facts` instead just refenced the next level directly, for example:

```
$ ansible -m setup centos1 |less
centos1 | SUCCESS => {
    "ansible_facts": {                              <- ignore root ansible_facts
        "ansible_all_ipv4_addresses": [
            "172.18.0.8"
        ],
        "ansible_all_ipv6_addresses": [],
        "ansible_apparmor": {
            "status": "disabled"
        },
        <...>
        "ansible_default_ipv4": {                   <- first key
            "address": "172.18.0.8",                <- sub key
            "alias": "eth0",
            "broadcast": "172.18.255.255",
            "gateway": "172.18.0.1",
````

So in the playbook it looks like this :
```
  tasks:
    - name: Show IP Address
      debug:
        msg: "{{ ansible_default_ipv4.address }}"

```
### Custom Facts
* By default Ansible expects to use `/etc/ansible/facts.d`
* Can by written in any language, but must Returns `json` | `ini` structure (`ìni` needs a catagory else it will fail.)
* Also available as `{{ hostvars[ansible_hostname].ansilbe_local.getdate1.date }}`

___

#### json example (must exist on remote system and be executable)
/etc/ansible/facts.d/getdate1.fact    
```
#!/bin/bash
echo {\""date\"" : \""`date`\""}
```
___

#### ini example (must exist on remote system and be executable)
/etc/ansible/facts.d/getdate2.fact 
```
#!/bin/bash
echo [date]
echo date=`date`
```
___
* If you now run the setup module it will run those custom facts and add them to `ansible_local` which can in this case be referenced with `ansible_local.getdate1.date` or `ansible_local.getdate2.date.date` in a playbook.
* These local vars can also be reference in hostvars:

          `{{ hostvars[ansible_hostname].ansible_local.getdate1.date }}`
          `{{ hostvars[ansible_hostname].ansible_local.getdate2.date.date }}`

```
$ ansible -m setup ubuntu-c -a 'filter=ansible_local'
ubuntu-c | SUCCESS => {
    "ansible_facts": {
        "ansible_local": {                                             <- first key
            "getdate1": {                                              <- sub key
                "date": "Thu Jul 25 09:29:38 UTC 2024"                 <- sub-sub key
            },
            "getdate2": {                                              <- sub key
                "date": {                                              <- sub-sub key
                    "date": "Thu Jul 25 09:29:38 UTC 2024"             <- sub-sub-sub key (because ini catagory)
                }
            }
        },
        "discovered_interpreter_python": "/usr/bin/python3.10"
    },
    "changed": false
}
```


### Example to propegate facts to a remote system , refresh facts and rerun.

```
---
# YAML documents begin with the document separator ---

# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
-

  # Hosts: where our play will run and options it will run with
  hosts: linux

  # Tasks: the list of tasks that will be executed within the play, this section
  # can also be used for pre and post tasks
  tasks:

    - name: Make Facts Dir
      file:
        path: /etc/ansible/facts.d
        recurse: yes
        state: directory

    - name: Copy Fact 1
      copy:
        src: /etc/ansible/facts.d/getdate1.fact
        dest: /etc/ansible/facts.d/getdate1.fact
        mode: 0755

    - name: Copy Fact 2
      copy:
        src: /etc/ansible/facts.d/getdate2.fact
        dest: /etc/ansible/facts.d/getdate2.fact
        mode: 0755

    - name: Refresh Facts
      setup:

    - name: Show IP Address
      debug:
        msg: "{{ ansible_default_ipv4.address }}"

    - name: Show Custom Fact 1
      debug:
        msg: "{{ ansible_local.getdate1.date }}"

    - name: Show Custom Fact 2
      debug:
        msg: "{{ ansible_local.getdate2.date.date }}"

    - name: Show Custom Fact 1 in hostvars
      debug:
        msg: "{{ hostvars[ansible_hostname].ansible_local.getdate1.date }}"

    - name: Show Custom Fact 2 in hostvars
      debug:
        msg: "{{hostvars[ansible_hostname].ansible_local.getdate2.date.date }}"

# Three dots indicate the end of a YAML document
...
```


### Example to propegate facts to a remote system , refresh facts and rerun. (Using non root custom factsdir)
```
---
# YAML documents begin with the document separator ---

# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
-

  # Hosts: where our play will run and options it will run with
  hosts: linux

  # Tasks: the list of tasks that will be executed within the play, this section
  # can also be used for pre and post tasks
  tasks:

    - name: Make Facts Dir
      file:
        path: /home/ansible/facts.d
        recurse: yes
        state: directory
        owner: ansible

    - name: Copy Fact 1
      copy:
        src: facts.d/getdate1.fact
        dest: /home/ansible/facts.d/getdate1.fact
        owner: ansible
        mode: 0755

    - name: Copy Fact 2
      copy:
        src: facts.d/getdate2.fact
        dest: /home/ansible/facts.d/getdate2.fact
        owner: ansible
        mode: 0755

    - name: Reload Facts
      setup:
        fact_path: /home/ansible/facts.d                              <- Important part

    - name: Show IP Address
      debug:
        msg: "{{ ansible_default_ipv4.address }}"

    - name: Show Custom Fact 1
      debug:
        msg: "{{ ansible_local.getdate1.date }}"

    - name: Show Custom Fact 2
      debug:
        msg: "{{ ansible_local.getdate2.date.date }}"

    - name: Show Custom Fact 1 in hostvars
      debug:
        msg: "{{ hostvars[ansible_hostname].ansible_local.getdate1.date }}"

    - name: Show Custom Fact 2 in hostvars
      debug:
        msg: "{{hostvars[ansible_hostname].ansible_local.getdate2.date.date }}"

# Three dots indicate the end of a YAML document
...
```

## Jinja2 templating

Jinja2 is a templating system commonly used for configuration files but it can also contain contains conditional statements.
The use of `break` and `continue` needs a special config in the `ansible.cfg` file :
```
jinja2_extensions = jinja2.ext.loopcontrols
```

Here are a few examples of how to use jinja2 in this playbook:
NOTE: the `-` at the end of the `if` statement is used to remove the CR char.
```
---
# YAML documents begin with the document separator ---

# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
-

  # Hosts: where our play will run and options it will run with
  hosts: all

  # Tasks: the list of tasks that will be executed within the play, this section
  # can also be used for pre and post tasks
  tasks:
    - name: Ansible Jinja2 if 
      debug:
        msg: >
             --== Ansible Jinja2 if statement ==--

             {# If the hostname is ubuntu-c, include a message -#}
             {% if ansible_hostname == "ubuntu-c" -%}
                   This is ubuntu-c
             {% endif %}

    - name: Ansible Jinja2 if elif
      debug:
        msg: >
             --== Ansible Jinja2 if elif statement ==--

             {% if ansible_hostname == "ubuntu-c" -%}
                This is ubuntu-c
             {% elif ansible_hostname == "centos1" -%}
                This is centos1 with it's modified SSH Port
             {% endif %}

    - name: Ansible Jinja2 if elif else
      debug:
        msg: >
             --== Ansible Jinja2 if elif else statement ==--

             {% if ansible_hostname == "ubuntu-c" -%}
                This is ubuntu-c
             {% elif ansible_hostname == "centos1" -%}
                This is centos1 with it's modified SSH Port
             {% else -%}
                This is good old {{ ansible_hostname }}
             {% endif %}


    - name: Ansible Jinja2 if variable is defined ( where variable is defined )
      debug:
        msg: >
             --== Ansible Jinja2 if variable is defined ( where variable is defined ) ==--

             {% set example_variable = 'defined' -%}
             {% if example_variable is defined -%}
                example_variable is defined
             {% else -%}
                example_variable is not defined
             {% endif %}

    - name: Ansible Jinja2 for statement
      debug:
        msg: >
             --== Ansible Jinja2 for statement ==--

             {% for entry in ansible_interfaces -%}
                Interface entry {{ loop.index }} = {{ entry }}
             {% endfor %}

    - name: Ansible Jinja2 for range
      debug:
        msg: >
             --== Ansible Jinja2 for range

             {% for entry in range(1, 11) -%}
                {{ entry }}
             {% endfor %}

    - name: Ansible Jinja2 for range, reversed (continue if odd)
      debug:
        msg: >
             --== Ansible Jinja2 for range, reversed (continue if odd) ==--

             {% for entry in range(10, 0, -1) -%}
                {% if entry is odd -%}
                   {% continue %}
                {% endif -%}
                {{ entry }}
             {% endfor %}

    - name: Ansible Jinja2 filters
      debug:
        msg: >
             ---=== Ansible Jinja2 filters ===---

             --== min [1, 2, 3, 4, 5] ==--

             {{ [1, 2, 3, 4, 5] | min }}

             --== max [1, 2, 3, 4, 5] ==--

             {{ [1, 2, 3, 4, 5] | max }}

             --== unique [1, 1, 2, 2, 3, 3, 4, 4, 5, 5] ==--

             {{ [1, 1, 2, 2, 3, 3, 4, 4, 5, 5] | unique }}

             --== difference [1, 2, 3, 4, 5] vs [2, 3, 4] ==--

             {{ [1, 2, 3, 4, 5] | difference([2, 3, 4]) }}

             --== random ['rod', 'jane', 'freddy'] ==--

             {{ ['rod', 'jane', 'freddy'] | random }}

             --== urlsplit hostname ==--

             {{ "http://docs.ansible.com/ansible/latest/playbooks_filters.html" | urlsplit('hostname') }}

    - name: Jinja2 template
      template:
        src: template.j2
        dest: "/tmp/{{ ansible_hostname }}_template.out"
        trim_blocks: true
        mode: 0644

# Three dots indicate the end of a YAML document
...
```