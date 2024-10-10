
# Notes for learning ansible
<!-- TOC tocDepth:2..3 chapterDepth:2..6 -->

- [Red Hat Installation](#red-hat-installation)
- [Distribute Key to managed hosts](#distribute-key-to-managed-hosts)
- [Get version of ansible](#get-version-of-ansible)
- [Anisible Config file Priority heirarchy](#anisible-config-file-priority-heirarchy)
- [Inventories](#inventories)
  - [Config](#config)
  - [inventory file](#inventory-file)
  - [Commands](#commands)
- [Modules](#modules)
  - [Setup Module](#setup-module)
  - [File Module](#file-module)
  - [Copy Module](#copy-module)
  - [fetch Module Example](#fetch-module-example)
  - [Command Module](#command-module)
- [Ansible Documentation](#ansible-documentation)
- [YAML](#yaml)
  - [<u>!- Single quote are litteral quotes, whereas double quotes are interpreted.</u>](#u--single-quote-are-litteral-quotes-whereas-double-quotes-are-interpretedu)
  - [<u>!- Multilines and single lines:</u>](#u--multilines-and-single-linesu)
  - [<u>!- Integers are automatically intepreted as INT unless quoted.</u>](#u--integers-are-automatically-intepreted-as-int-unless-quotedu)
  - [<u>!- Lists `[]` are assigned with `-`</u> an these actually create a python list.](#u--lists-are-assigned-with--u-an-these-actually-create-a-python-list)
  - [<u>!- Dictionaries `{}` are assigned with  key `:` value  </u> an these actually create a python dictionary.](#u--dictionaries-are-assigned-with-key-value-u-an-these-actually-create-a-python-dictionary)
  - [<u>!- Indentation </u>](#u--indentation-u)
  - [Useful Links:](#useful-links)
- [Playbooks](#playbooks)
  - [Structure](#structure)
  - [Some important notes:](#some-important-notes)
- [Variables](#variables)
  - [Different way to set and access variables:](#different-way-to-set-and-access-variables)
  - [Passing in Extravars](#passing-in-extravars)
  - [Vars as directory/files](#vars-as-directoryfiles)
- [Ansible Playbooks, Facts](#ansible-playbooks-facts)
  - [Facts](#facts)
  - [Custom Facts](#custom-facts)
  - [Example to propegate facts to a remote system , refresh facts and rerun.](#example-to-propegate-facts-to-a-remote-system-refresh-facts-and-rerun)
  - [Example to propegate facts to a remote system , refresh facts and rerun. (Using non root custom factsdir)](#example-to-propegate-facts-to-a-remote-system-refresh-facts-and-rerun-using-non-root-custom-factsdir)
- [Jinja2 templating](#jinja2-templating)
  - [Example playbook](#example-playbook)
- [Playbooks - Advanced!](#playbooks---advanced)
  - [Useful Modules](#useful-modules)
- [Dynamic Inventories](#dynamic-inventories)
  - [Example - inventory.py](#example---inventorypy)
- [Register and When](#register-and-when)
  - [Register](#register)
  - [When](#when)
- [Looping](#looping)
  - [with_items](#with_items)
  - [with_fileglob](#with_fileglob)
  - [with_inventory_hostnames](#with_inventory_hostnames)
  - [with_dict](#with_dict)
  - [with_subelements](#with_subelements)
  - [Using Loops to work with Keys:](#using-loops-to-work-with-keys)
- [Perfomance](#perfomance)
  - [](#)

<!-- /TOC -->
## Red Hat Installation
```
enable Ansible RPMS in /etc/yum.repos.d/redhat.repo
sudo dnf update
sudo dnf install ansible

```

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
* Note that the first comma after -i is important to tell Ansible you are providing a list of hosts directly instead of pointing to a file.
* Even though you listed the hosts manually, you can still use the keyword all to apply the module to all the provided hosts.

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

-> `"{{ var_name }}"` is a Jinja2 variable used by the jinja2 templating system. In Ansible playbooks, Jinja2 template expressions <b>should be quoted</b> to ensure they are correctly interpreted.

-> Handlers use the notify key inside a task. the execute once after there has been a change. `notify:`and `when:` will call the `handler`matching the `notify` name. 

-> Here we gather facts so we can get the `ansible_distribution` variable.

```
---
# YAML documents begin with the document separator ---
 
# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
- 
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

#### variables_playbook.yaml (playbook)  -> Here we read a variable file in with vars_files:
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

### Example playbook
* This playbook will direct actions to the linux group which contains 3 centos hosts and 3 ubuntu hosts.
* It will read in a variable file
* install epel on centos hosts (Extra Packages for Enterprise Linux (EPEL) repository. EPEL is a repository of high-quality add-on packages for Linux distributions such as Red Hat Enterprise Linux (RHEL), CentOS, and Fedora. These packages are maintained by the Fedora Project and provide additional software that is not included in the standard RHEL/CentOS repositories. )
* Install Nginx and unzip using dnf 
* we set this in `ansible.cfg` and reference this variable in our src template file so people know the file is ansible managed.
* we install a html landing page and unzip a file as an easter egg. After nginx restarts there is a notify to a handler to check if we still get HTTP status 200
 ```
[defaults]
ansible_managed = Managed by Ansible - file : {file} - host:{host} - uid:{uid}
 ```
___

```
---
# YAML documents begin with the document separator ---

# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
-

  # Hosts: where our play will run and options it will run with
  hosts: linux

  # Vars: variables that will apply to the play, on all target systems
  vars_files: 
    - vars/logos.yaml

  # Tasks: the list of tasks that will be executed within the play, this section
  # can also be used for pre and post tasks
  tasks:

    - name: Install Epel on centos
      ansible.builtin.dnf:
        name: epel-release
        update_cache: yes
        state: latest
      when: ansible_distribution == 'CentOS'

    - name: Install Nginx
      ansible.builtin.package:
        name: nginx
        update_cache: yes
        state: latest

    - name: Install unzip
      ansible.builtin.package:
        name: unzip
        update_cache: yes
        state: latest

    - name: Restart Nginx
      ansible.builtin.service:
        name: nginx
        state: restarted
      notify:
        - Check HTTP Service

    - name: Template index.html-ansible_managed.j2 to index.html on target
      ansible.builtin.template:
        src: index.html-easter_egg.j2
        dest: "{{ nginx_root_location }}/index.html"
        mode: 0644

    - name: Unarchive playbook stacker game
      ansible.builtin.unarchive:
        src: playbook_stacker.zip
        dest: "{{ nginx_root_location }}"
        mode: 0755

  # Handlers: the list of handlers that are executed as a notify key from a task
  handlers:
    - name: Check HTTP Service 
      ansible.builtin.uri:
        url: http://{{ ansible_default_ipv4.address }}
        status_code: 200

# Three dots indicate the end of a YAML document
...
```
___

## Playbooks - Advanced!
### Useful Modules
#### set_fact:
To get module information i find the best is to use eg) `ansible-doc set_fact` This allows you to see how it works, what flags can be added and most helpful it provides examples at the bottom.
```
---
-

  #hosts
  hosts: ubuntu2, centos2

  #tasks
  tasks:
    - name: Set custom facts if dist is Ubuntu
      ansible.builtin.set_fact:
        PORT: 80
        DIR: /var/www/html
        USER: ansible
      when: ansible_distribution == "Ubuntu"

    - name: Set custom facts if dist is Centos
      ansible.builtin.set_fact:
        PORT: 8080
        DIR: /var/www/html2
        USER: webuser
      when: ansible_distribution == "CentOS"    

    - name: print facts
      ansible.builtin.debug:
        msg: "Port:{{PORT}} Dir {{DIR}} User: {{USER}}" 
  #handlers

...
````
___
#### wait_for: 
```
---
-
  hosts: ubuntu2, centos2

  tasks:
    - name: stop nginx
      ansible.builtin.service:
        name: nginx
        state: stopped

    - name: Check when up
      ansible.builtin.wait_for:
        port: 80
        state: started
        msg: "checking when up"
      notify: webserver up

  handlers:
    - name: webserver up
      ansible.builtin.debug:
        msg: "Webserver up"
...
```
___
#### assemble:
```
---
-

  hosts: ubuntu-c

  tasks:
    - name: Assemble configs
      ansible.builtin.assemble:
        src: conf.d
        dest: sshd_config
...
````
___
#### add_host:
Here we use 2 plays in the playbook, this is done with `-`
```
---
-
  #hosts
  hosts: ubuntu-c

  #tasks
  tasks:
    - name: Add host to adhoc groups
      ansible.builtin.add_host:
        name: centos1
        groups: adhoc1, adhoc2

  #handlers

- 
  #hosts
  hosts: adhoc1

  #tasks
  tasks:
    - name: ping all hosts
      ansible.builtin.ping:

  #handlers
  
...
```
___
#### group_by:
```
---
-
  #hosts
  hosts: ubuntu-c

  #tasks
  tasks:
    - name: Add host to adhoc groups
      ansible.builtin.add_host:
        name: centos1
        groups: adhoc1, adhoc2

  #handlers

- 
  #hosts
  hosts: adhoc1

  #tasks
  tasks:
    - name: ping all hosts
      ansible.builtin.ping:

  #handlers
  
...
````
___
#### fetch:
```
---
-
  #hosts
  hosts: centos

  #tasks
  tasks:
    - name: Fetch /etc/redhat-release
      ansible.builtin.fetch:
        src: /etc/redhat-release
        dest: dump

  #handlers
...
```
___

## Dynamic Inventories
* Needs to be an executable file.
* Can be written in any language providing that it can be executed from the command line
* Accepts the command line options of --list and --host hostname
* returns a JSON enconded dictionary of inventory content with --list
* returns a basic JSON enconded dictionary for --host hostname
* AWS dynamic inventories is a good template if you want to develop an interface with your own internal inventory system.

### Example - inventory.py
```
#!/usr/bin/env python3

'''
Dynamic inventory for Ansible in Python
'''

# Use print functionality from Python 3 for compatibility
from __future__ import print_function

import argparse
import logging

# Attempt to import json, if it fails, import simplejson
try:
    import json
except ImportError:
    import simplejson as json

# Inherit from object for Python 2/3 compatibility
class Inventory(object):

    # Constructor
    def __init__(self, include_hostvars_in_list):

        # Configure logger
        #self.configure_logger()

        # Capture and store include_hostvars_in_list
        self.include_hostvars_in_list = include_hostvars_in_list

        # Capture the script command line arguments
        parser = argparse.ArgumentParser()
        parser.add_argument('--list', action='store_true',
                            help='list inventory')
        parser.add_argument('--host', action='store',
                            help='show HOST variables')
        self.args = parser.parse_args()

        # If not called with --host or --list, show usage and exit
        if not (self.args.list or self.args.host):
            parser.print_usage()
            raise SystemExit

        # Capture and store the inventory
        self.define_inventory()

        # When called with --list, print the inventory
        if self.args.list:
            self.print_json(self.list())

        # If called with --host, print host information
        elif self.args.host:
            self.print_json(self.host())

    def define_inventory(self):
        self.groups = {
            "centos": {
                "hosts": ["centos1", "centos2", "centos3"],
                "vars": {
                    "ansible_user": 'root'
                }
            },
            "control": {
                "hosts": ["ubuntu-c"],
            },
            "ubuntu": {
                "hosts": ["ubuntu1", "ubuntu2", "ubuntu3"],
                "vars": {
                    "ansible_become": True,
                    "ansible_become_pass": 'password'
                }
            },
            "linux": {
                "children": ["centos", "ubuntu"],
            }}

        self.hostvars = {
            'centos1': {
                'ansible_port': 22
            },
            'ubuntu-c': {
                'ansible_connection': 'local'
            }
        }

    # Pretty print JSON
    def print_json(self, content):
        print(json.dumps(content, indent=4, sort_keys=True))

    # Return inventory dictionary
    def list(self):

        #self.logger.info('list executed')

        # If include_hostvars_in_list is True, merge the hostvars
        # as _meta data
        if self.include_hostvars_in_list:
            merged = self.groups
            merged['_meta'] = {}
            merged['_meta']['hostvars'] = self.hostvars
            return merged

        # Otherwise, return the groups without hostvars
        else:
            return self.groups

    # Return host dictionary
    def host(self):

        #self.logger.info('host executed for {}'.format(self.args.host))

        # If the requested hosts exists in hostvars, return it
        if self.args.host in self.hostvars:
            return self.hostvars[self.args.host]

        # Otherwise, return an empty list
        else:
            return {}

    # Logger, for debugging as stdout is used by the script
    def configure_logger(self):
        self.logger = logging.getLogger('ansible_dynamic_inventory')
        self.hdlr = logging.FileHandler('/var/tmp/ansible_dynamic_inventory.log')
        self.formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
        self.hdlr.setFormatter(self.formatter)
        self.logger.addHandler(self.hdlr) 
        self.logger.setLevel(logging.DEBUG)

# Call the Inventory class constructor (__init__)
# Pass include_hostsvars_in_list as True to include hostvars
# as _meta data in list output
Inventory(include_hostvars_in_list=False)
```

## Register and When
### Register
This can be used in most modules to create a variable/fact. 
```
---
-
  #hosts
  hosts: all

  #tasks
  tasks:
    - name: Explore register
      ansible.builtin.command:
        cmd: hostname -s
      register: name

    - name: print var
      ansible.builtin.debug:
        msg: "hostname is {{ name.stdout }}"

  #handlers
...
```
Result:
```
ok: [ubuntu-c] => {
    "msg": "hostname is {'changed': True, 'stdout': 'ubuntu-c', 'stderr': '', 'rc': 0, 'cmd': ['hostname', '-s'], 'start': '2024-08-02 07:13:08.402118', 'end': '2024-08-02 07:13:08.404075', 'delta': '0:00:00.001957', 'msg': '', 'stdout_lines': ['ubuntu-c'], 'stderr_lines': [], 'failed': False}"
}
ok: [centos1] => {
    "msg": "hostname is {'changed': True, 'stdout': 'centos1', 'stderr': '', 'rc': 0, 'cmd': ['hostname', '-s'], 'start': '2024-08-02 07:13:08.430362', 'end': '2024-08-02 07:13:08.432887', 'delta': '0:00:00.002525', 'msg': '', 'stdout_lines': ['centos1'], 'stderr_lines': [], 'failed': False}"
}
ok: [centos2] => {
    "msg": "hostname is {'changed': True, 'stdout': 'centos2', 'stderr': '', 'rc': 0, 'cmd': ['hostname', '-s'], 'start': '2024-08-02 07:13:08.439861', 'end': '2024-08-02 07:13:08.441343', 'delta': '0:00:00.001482', 'msg': '', 'stdout_lines': ['centos2'], 'stderr_lines': [], 'failed': False}"
}
ok: [centos3] => {
    "msg": "hostname is {'changed': True, 'stdout': 'centos3', 'stderr': '', 'rc': 0, 'cmd': ['hostname', '-s'], 'start': '2024-08-02 07:13:08.439563', 'end': '2024-08-02 07:13:08.441136', 'delta': '0:00:00.001573', 'msg': '', 'stdout_lines': ['centos3'], 'stderr_lines': [], 'failed': False}"
}
ok: [ubuntu1] => {
    "msg": "hostname is {'changed': True, 'stdout': 'ubuntu1', 'stderr': '', 'rc': 0, 'cmd': ['hostname', '-s'], 'start': '2024-08-02 07:13:08.456060', 'end': '2024-08-02 07:13:08.457332', 'delta': '0:00:00.001272', 'msg': '', 'stdout_lines': ['ubuntu1'], 'stderr_lines': [], 'failed': False}"
}
ok: [ubuntu2] => {
    "msg": "hostname is {'changed': True, 'stdout': 'ubuntu2', 'stderr': '', 'rc': 0, 'cmd': ['hostname', '-s'], 'start': '2024-08-02 07:13:08.575506', 'end': '2024-08-02 07:13:08.576585', 'delta': '0:00:00.001079', 'msg': '', 'stdout_lines': ['ubuntu2'], 'stderr_lines': [], 'failed': False}"
}
ok: [ubuntu3] => {
    "msg": "hostname is {'changed': True, 'stdout': 'ubuntu3', 'stderr': '', 'rc': 0, 'cmd': ['hostname', '-s'], 'start': '2024-08-02 07:13:08.589289', 'end': '2024-08-02 07:13:08.590358', 'delta': '0:00:00.001069', 'msg': '', 'stdout_lines': ['ubuntu3'], 'stderr_lines': [], 'failed': False}"
}
```

Register creates a dictionary object which can be queried with dot notation. In this case we are pulling out the stdout part, but there is much more :
```
{
  'changed': True,
  'stdout': 'ubuntu3', 
  'stderr': '', 
  'rc': 0, 
  'cmd': ['hostname', '-s'], 
  'start': '2024-08-02 07:13:08.589289', 
  'end': '2024-08-02 07:13:08.590358', 
  'delta': '0:00:00.001069', 
  'msg': '', 
  'stdout_lines': ['ubuntu3'], 
  'stderr_lines': [], 
  'failed': False
  }
```

### When
When (like register) is used outside the module and applies to most modules. Below we can provide multiple conditions that the task needs to meet in order for it to be executed.

```
---
-
  # hosts
  hosts: all

  # vars
  
  # tasks
  tasks:
    - name: get hostname for specific dists
      ansible.builtin.command:
        cmd: hostname -s
      when: ( ansible_distribution == "CentOS" and ansible_distribution_major_version == 9 ) or 
            ( ansible_distribution == "Ubuntu" and ansible_distribution_major_version == 22 )

    - name: debuging
      ansible.builtin.debug:
        msg: "ansible_distribution is {{ansible_distribution}}. ansible_distribution_major_version is {{ansible_distribution_major_version }} "

  # handlers
...
```

Result:
```
PLAY [all] *************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************************************************
ok: [ubuntu-c]
ok: [centos3]
ok: [centos2]
ok: [centos1]
ok: [ubuntu1]
ok: [ubuntu3]
ok: [ubuntu2]

TASK [get hostname for specific dists] *********************************************************************************************************************************************************************************************************
skipping: [ubuntu-c]
skipping: [centos1]
skipping: [centos2]
skipping: [centos3]
skipping: [ubuntu1]
skipping: [ubuntu2]
skipping: [ubuntu3]

TASK [debuging] ********************************************************************************************************************************************************************************************************************************
ok: [ubuntu-c] => {
    "msg": "ansible_distribution is Ubuntu. ansible_distribution_major_version is 22 "
}
ok: [centos1] => {
    "msg": "ansible_distribution is CentOS. ansible_distribution_major_version is 9 "
}
ok: [centos2] => {
    "msg": "ansible_distribution is CentOS. ansible_distribution_major_version is 9 "
}
ok: [centos3] => {
    "msg": "ansible_distribution is CentOS. ansible_distribution_major_version is 9 "
}
ok: [ubuntu1] => {
    "msg": "ansible_distribution is Ubuntu. ansible_distribution_major_version is 22 "
}
ok: [ubuntu2] => {
    "msg": "ansible_distribution is Ubuntu. ansible_distribution_major_version is 22 "
}
ok: [ubuntu3] => {
    "msg": "ansible_distribution is Ubuntu. ansible_distribution_major_version is 22 "
}

PLAY RECAP *************************************************************************************************************************************************************************************************************************************
centos1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
centos2                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
centos3                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
ubuntu-c                   : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
ubuntu1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
ubuntu2                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
ubuntu3                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

```

Another way to use it is as follows:

```
---
-
  # hosts
  hosts: all

  # vars
  
  # tasks
  tasks:
    - name: get hostname for specific dists
      ansible.builtin.command:
        cmd: hostname -s
      when:
        - ansible_distribution == "CentOS"
        - ansible_distribution_major_version | int >= 8
      register: cmdreg

    - name: debuging
      ansible.builtin.debug:
        msg: "This host has CentOS with major v8 or higher"
      when: cmdreg is changed

    - name: debuging
      ansible.builtin.debug:
        msg: "This host has not CentOS"
      when: cmdreg is skipped

  # handlers
...
```

Result:
```

PLAY [all] ************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************************************************************
ok: [ubuntu-c]
ok: [centos1]
ok: [centos3]
ok: [centos2]
ok: [ubuntu1]
ok: [ubuntu2]
ok: [ubuntu3]

TASK [get hostname for specific dists] ********************************************************************************************************************************************************************************
skipping: [ubuntu-c]
skipping: [ubuntu1]
skipping: [ubuntu2]
skipping: [ubuntu3]
changed: [centos2]
changed: [centos1]
changed: [centos3]

TASK [debuging] *******************************************************************************************************************************************************************************************************
skipping: [ubuntu-c]
ok: [centos1] => {
    "msg": "This host has CentOS with major v8 or higher"
}
ok: [centos2] => {
    "msg": "This host has CentOS with major v8 or higher"
}
ok: [centos3] => {
    "msg": "This host has CentOS with major v8 or higher"
}
skipping: [ubuntu1]
skipping: [ubuntu2]
skipping: [ubuntu3]

TASK [debuging] *******************************************************************************************************************************************************************************************************
ok: [ubuntu-c] => {
    "msg": "This host has not CentOS"
}
skipping: [centos1]
skipping: [centos2]
skipping: [centos3]
ok: [ubuntu1] => {
    "msg": "This host has not CentOS"
}
ok: [ubuntu2] => {
    "msg": "This host has not CentOS"
}
ok: [ubuntu3] => {
    "msg": "This host has not CentOS"
}

PLAY RECAP ************************************************************************************************************************************************************************************************************
centos1                    : ok=3    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
centos2                    : ok=3    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
centos3                    : ok=3    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
ubuntu-c                   : ok=2    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
ubuntu1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
ubuntu2                    : ok=2    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
ubuntu3                    : ok=2    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
```

## Looping
There are mans with Items that exists, below are a few:

| loop name                  | Explanation                                                    |
|----------------------------|----------------------------------------------------------------|
| `with`                     | group of loops                                                 |
| `with_items`               | a simple list                                                  |
| `with_nested`              | list of lists                                                  |
| `with_dict`                | loop on a dictionary                                           |
| `with_fileglob`            | list of files in dir(pattern match). Not recursive             |
| `with_filetree`            | same as fileglob but recursive                                 |
| `with_together`            | combine 2 lists eg (A,B,C) (1,2,3)  A related to 1 and so forth|
| `with_sequence`            | range with interval                                            |
| `with_random_choice`       | select a random value in a list                                |
| `with_first_found`         | select first element                                           |
| `with_lines`               | get each line of a file                                        |
| `with_ini`                 | browse a file with ini format                                  |
| `with_inventory_hostnames` | get hosts of the inventory file                                |
| `with_subelements`         | list of dictionaries                                           |
| `with_netsted`             | for each of these, do each of these loop                       |
| `with_file`                | pass in a list of files                                        |



### with_items
* This will loop over each list item `-`so in the first case the first item is a dictionary.

* * `{dir: "dir1", file: "fileA" }` and each item is referenced with `ìtem.dir` and `item.file`
* in Python the dictionary will look like this:
* * `item={ "dir":"dir1", "file":"fileA" }` and each item is referenced with `item["dir"]` and `item["file"]`

```
---
-
  #hosts
  hosts: linux

  tasks:
    - name: create directories using with_items
      ansible.builtin.file:
        path: /home/ansible/playgroup/with_items/{{ item.dir }}/{{ item.file }}
        state: touch
        recurse: yes
      with_items:
        - {dir: "dir1", file: "fileA" }
        - {dir: "dir2", file: "fileB" }
        - {dir: "dir3", file: "fileC" }
        - {dir: "dir4", file: "fileD" }
...                                     
```

Another way to do this (and possibly beter). Important is whenever referencing a var it must be quoted `"{{ my_list }}"`:
```
---
-
  #hosts
  hosts: linux

  #vars:
  vars:
    my_list:
    - {dir: "dir1", file: "fileA" }
    - {dir: "dir2", file: "fileB" }
    - {dir: "dir3", file: "fileC" }
    - {dir: "dir4", file: "fileD" }

  tasks:
    - name: create directories using with_items
      ansible.builtin.file:
        path: /home/ansible/playgroup/with_items/{{ item.dir }}/{{ item.file }}
        state: touch
      with_items:
      - "{{ my_list }}"
...                                          
```

### with_fileglob
Here you can specify a source directory and copy all files from that dir matching a certain pattern to a remote location.

```
---
-
  #hosts
  hosts: linux

  tasks:
    - name: create directories using with_items
      ansible.builtin.file:
        path: "/home/ansible/playgroup/with_items/{{ item | basename }}"
        state: touch
      with_fileglob:
      - filesSRC/file*.txt 
...
```

### with_inventory_hostnames
You can use this to create directories with each server name belonging to group `all`
```
---
-
  #hosts
  hosts: linux

  tasks:
    - name: create directories using with_items
      ansible.builtin.file:
        path: "/tmp/{{ item }}"
        state: touch
      with_inventory_hostname:
      - all
...
```

On the remote system :
```
$ ls -lt /home/ansible/playgroup/with_items/fil*
-rw-r--r-- 1 ansible ansible 0 Aug  6 06:07 /home/ansible/playgroup/with_items/fileA.txt
-rw-r--r-- 1 ansible ansible 0 Aug  6 06:07 /home/ansible/playgroup/with_items/fileC.txt
-rw-r--r-- 1 ansible ansible 0 Aug  6 06:07 /home/ansible/playgroup/with_items/fileB.txt
```


### with_dict

```
---
-
  #hosts
  hosts: linux

  #tasks
  tasks:
    - name: Create Users
      ansible.builtin.user:
        name: "{{ item.key }}"                  
        comment: "{{ item.value.full_name }}"
      with_dict:                                <- dictionary called with_dict contains other dicts
        balls:                                  <- This is a dict called balls
          full_name: "Snowball AKA Balls"       <- with key:value pair
        noopie:
          full_name: "Roxy AKA Scnhoofie"
        numbnuts:
          full_name: "Spanner"
        numlocks:
          full_name: "Mr Random"

  #handlers
...
```

user_dict in Python has both keys and values. The keys are the names like "balls," "noopie," "numbnuts," and "numlocks," and the values are nested dictionaries containing another key "full_name" and its corresponding value. So in this case the dictionary structure looks like this:
```
user_dict = {
    "balls": {
        "full_name": "Snowball AKA Balls"
    },
    "noopie": {
        "full_name": "Roxy AKA Scnhoofie"
    },
    "numbnuts": {
        "full_name": "Spanner"
    },
    "numlocks": {
        "full_name": "Mr Random"
    }
}
```
* user_dict is derived from your Ansible with_dict structure. Outer dictionary called user_dict has a key called balls. the value of balls is a dictionary itself.
* <b>Outer dictionary:</b> This has four keys: "balls," "noopie," "numbnuts," and "numlocks."
* <b>Values of the outer</b> dictionary: Each of these keys maps to another dictionary.
* <b>Inner dictionaries</b>: Each inner dictionary has a single key "full_name" with a corresponding value that is a string (e.g., "Snowball AKA Balls" for the key "balls").
___

### with_subelements
This is a breakdown exaplanation of `with_subelements`
```
---
-
  #hosts
  hosts: linux

  #tasks
  tasks:
    - name: Create Users
      ansible.builtin.user:
        name: "{{ item.1 }}"                                 
        comment: "{{ item.1 | title }} {{item.0.surname }}"  
      with_subelements:                                     
        - family:
            surname: Ryan
            members:
              - Aid
              - Tan
              - Gar
              - Kay
        - members                                       
  #handlers
...
```

* `with_subelements:` - This directive is used to iterate over a list of dictionaries and their subelements (nested lists).
* The with_subelements takes two parameters:
* The <b>first</b> is a list of dictionaries. In this case there is only 1 dict (family)
* The <b>second</b> is the key within each dictionary to iterate over.

#### Structure
* The family dictionary contains a surname key and a members key.
* members is a list of names.

#### Iteration Process
The `with_subelements` iterates over each element in the `family` dictionary and then over each element in the members list.

#### Variables `item.0` and `item.1`
* `item.0` refers to the parent element (in this case, each family dictionary).
* `item.1` refers to the subelement (each member in the members list).

#### Task Details
name: "{{ item.1 }}":
* `item.1` is each member name from the members list.

comment: "{{ item.1 | title }} {{ item.0.surname }}":
* `item.1 | title` converts the member name to title case.

`item.0.surname` accesses the surname key from the family dictionary.

#### Step-by-Step Execution
##### First Iteration:
`item.0` is the family dictionary.

`item.1` is "Aid".

* The task creates a user with:
```
name: "Aid"
comment: "Aid Ryan"
```

##### Second Iteration:
`item.1` is "Tan".
The task creates a user with:

```
name: "Tan"
comment: "Tan Ryan"
```
...

In Python is looks like this:
```
family_dict = {
    "family": {
        "surname": "Ryan",
        "members": ["Aid", "Tan", "Gar", "Kay"]
    }
}
```

##### Iteration Breakdown:
* The with_subelements loops through each family dictionary and its members sublist.
* For each member in members, Ansible uses `item.1` for the member name and `item.0.surname` for the surname.

##### Summary
* `with_subelements` is used to iterate through nested lists within dictionaries.
* `item.0` refers to the outer dictionary.
* `item.1` refers to the elements in the nested list.
* For each member in members, a user is created with the member's name and a comment combining the member's name (in title case) and the surname.      

### Using Loops to work with Keys:

#### Example 1
Here we use the `with_file` loop and the `authorized_keys` module to copy the current users public key to the authorized_keys file.

```
---
# YAML documents begin with the document separator ---
 
# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
-
 
  # Hosts: where our play will run and options it will run with
  hosts: linux
 
  # Tasks: the list of tasks that will be executed within the playbook
  tasks:
    - name: Create authorized key
      authorized_key:
        user: james
        key: "{{ item }}"
      with_file:
        - /home/ansible/.ssh/id_rsa.pub


# Three dots indicate the end of a YAML document
...
```

#### Example 2
We use `with_sequence` to create a list of directories with skip interval of 10.

```
---
# YAML documents begin with the document separator ---
 
# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
-
 
  # Hosts: where our play will run and options it will run with
  hosts: linux
 
  # Tasks: the list of tasks that will be executed within the playbook
  tasks:
    - name: Create sequence directories
      file:
        dest: "/home/james/sequence_{{ item }}"
        state: directory
      with_sequence: start=0 end=100 stride=10

# Three dots indicate the end of a YAML document
...
```

#### Example 3
Same as above but resulting in decimal output. You can use hex(`%x`) or Octal too.

```
---
# YAML documents begin with the document separator ---
 
# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
-
 
  # Hosts: where our play will run and options it will run with
  hosts: linux
 
  # Tasks: the list of tasks that will be executed within the playbook
  tasks:
    - name: Create sequence directories
      file:
        dest: "{{ item }}"
        state: directory
      with_sequence: start=0 end=100 stride=10 format=/home/james/sequence_%d

# Three dots indicate the end of a YAML document
...
```

#### Example 4
This uses `with_random_choice`to randomly select and item from the list.
```
---
# YAML documents begin with the document separator ---
 
# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
-
 
  # Hosts: where our play will run and options it will run with
  hosts: linux
 
  # Tasks: the list of tasks that will be executed within the playbook
  tasks:
    - name: Create random directory
      file:
        dest: "/home/james/{{ item }}"
        state: directory
      with_random_choice:
        - "google"
        - "facebook"
        - "microsoft"
        - "apple"

# Three dots indicate the end of a YAML document
...
```
___
#### Example 5
This runs a script with an until condition. We register the result, and make it run max 100x with a delay of 100ms

`until: result.stdout.find("10") != -1` 
This specifies a condition to determine if the task should be retried. The task will keep running until the condition evaluates to True. In this case, it checks if the string "10" is found in the standard output (stdout) of the script. The find method returns the index of the first occurrence of the substring, or -1 if it is not found.

For tasks that run commands or scripts, the registered variable typically has the following structure:

* `result.stdout`: Standard output from the command or script.
* `result.stderr`: Standard error from the command or script.
* `result.rc`: Return code of the command or script.
* `result.changed`: Boolean indicating if the task caused any change.
* `result.failed`: Boolean indicating if the task failed.

script:
```
#!/bin/bash
echo $((1 + RANDOM % 10))
```

Playbook:
```
---
-
  hosts: ubuntu-c

  tasks:
    - name: Loop test
      ansible.builtin.script: ./random.sh
      register: result
      until: result.stdout.find("10") != -1
      retries: 100
      delay: 0.1
...
```
___
## Perfomance
### 
* `Linear strategy`: Ansible will wait for a task to complete on all hosts before moving to the next task.

