#!/bin/bash
set -e

host_number=1
account="root"
passwd="123456"

#main function
function usage {
    cat <<EOF
Usage: $0  [options] -- COMMAND

Options:
    --host-number   Number of host that you want to generate, default is 1

Commands:
    start       Bring up all the containers for Ansible hosts
    clear       Teardown all the containers
    build       Build the docker image for all hosts
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
    (--host-number)
        host_number=$2
        shift 2
        ;;
    (--)
        shift
        break
        ;;
    (*)
        usage
        exit 3
        ;;
esac
done

case "$1" in

(start)
        echo "start all the Ansible hosts"
        cp -f template/inventory template/ansiblehost
        docker run -d --name=master --label ansible=ansible_cluster --privileged centos:ansible
        slave_host=`echo $[host_number-1]`
        if (( $slave_host == 0 )); then
            echo "start Ansible master successfully"
            exit 0
        fi
        for i in $( eval echo {1..$slave_host} );
        do 
            docker run -d --name=slave-$i --label ansible=ansible_cluster --privileged centos:ansible
            ip=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' slave-$i`
            docker exec -it master expect /root/ssh-copy-expect $account@$ip $passwd
            sed -i '/\[ansible\]/a '$ip' ansible_user='$account' ansible_password='$passwd'' template/ansiblehost
        done
        docker cp template/ansiblehost master:/root/
        docker cp ansible master:/root/

        echo "start all the Ansible hosts successfully"
        ;;
(clear)
        echo "clear all the hosts"
        docker rm -f $(docker ps -a -q --filter "label=ansible=ansible_cluster")
        echo "clear all the hosts successfully"
        ;;
(build)
        echo "build the image for all hosts"
        docker build -t=centos:ansible -f build/dockerfile .
        echo "build the image for all hosts successfully"
        ;;
(*)     usage
        exit 0
        ;;
esac