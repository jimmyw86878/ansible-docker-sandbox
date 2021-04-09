## Description

This repository can create [Ansible](https://docs.ansible.com/ansible/latest/index.html) cluster (one master and multiple slaves) for testing, scaling, learning your Ansible playbooks. Just use a simple command to set up multiple containerized Ansible hosts in one minute and you can run your playbooks of Ansible.

All SSH configuration will be pre-configured for the usage of Ansible. Users don't need to care about it.

## Prerequisite

- [Docker](https://docs.docker.com/engine/install/)

## Build

Each Ansible host is using the same docker image (Centos7 based).

```
sudo bash ansible_env.sh -- build
```

Check the image 

```
docker images

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              ansible             4bbf5b95823a        3 days ago          886MB
```

## Getting started

Bring up all the Ansible hosts:

```
sudo bash ansible_env.sh --host-number 3 -- start
```

- `--host-number` option allows you to assign the total number of Ansible host. (Example: 3, one master and two slaves)
- Minimal number of hosts will be 1. Default is 1 and just create a single Ansible master. 

During the process of above command, it will show up some prompts about SSH configuration. Just ignore these prompts since they will be filled automatically by the script.

Check the Ansible hosts

```
docker ps -a

CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS               NAMES
91c3554e5e29        centos:ansible      "/usr/sbin/sshd -D"   28 seconds ago      Up 26 seconds       22/tcp              slave-2
7d5662ec40b1        centos:ansible      "/usr/sbin/sshd -D"   35 seconds ago      Up 34 seconds       22/tcp              slave-1
3747f75802e4        centos:ansible      "/usr/sbin/sshd -D"   36 seconds ago      Up 35 seconds       22/tcp              master
```

You can enter master container to test and write your Ansible playbooks. There is a default playbook named `main.yml` in master.

Enter master container:
```
doceker exec -it master bash
```

Run the playbooks 
```
ansible-playbook -i /root/ansiblehost /root/ansible/main.yml
```

- Inventory: `ansiblehost` is generated from the script and it stores the information of all the Ansible hosts.
- The account and password of each Ansible host are `root` and `123456`.

Result:
```
PLAY [test area] *******************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [172.17.0.4]
ok: [172.17.0.3]
ok: [localhost]

TASK [get hostname] ****************************************************************************************************************************************************************************************
changed: [172.17.0.3]
changed: [localhost]
changed: [172.17.0.4]

TASK [debug] ***********************************************************************************************************************************************************************************************
ok: [172.17.0.4] => {
    "msg": "5dc6ef515e43"
}
ok: [172.17.0.3] => {
    "msg": "f19a0d4ef05d"
}
ok: [localhost] => {
    "msg": "c1b7d6c28413"
}

PLAY RECAP *************************************************************************************************************************************************************************************************
172.17.0.3                 : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
172.17.0.4                 : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
## Teardown all Ansible hosts

To erase all the containerized Ansible hosts:

```
sudo bash ansible_env.sh -- clear
```