## Description

This repository can create [Ansible](https://docs.ansible.com/ansible/latest/index.html) cluster (one master and multiple slaves) for testing, scaling, learning your Ansible playbooks. Just use a simple command to set up multiple containerized Ansible hosts in one minute and you can run your playbooks of Ansible.

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

You can enter master container to test and write your Ansible playbooks. There are a default playbook `main.yml` in master.

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

## Teardown all Ansible hosts

To erase all the containerized Ansible hosts:

```
sudo bash ansible_env.sh -- clear
```