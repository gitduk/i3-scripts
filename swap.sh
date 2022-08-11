#!/bin/bash

mode=$1

if [ "$mode" == "-d" ];then
    echo 'Start by deactivating the swap space.'
    sudo swapoff -v /swapfile

    echo 'Remove the swap file entry "/swapfile swap swap defaults 0 0" from the /etc/fstab file.'
    sudo sed -i '/^\/swapfile/d' /etc/fstab

    echo 'Remove the actual swapfile file.'
    sudo rm /swapfile
fi

if [ "$mode" == "-c" ];then
    size=$2
    unit=${size: -1}
    num=${size%?}

    if [ "$unit" == "G" ];then
        bt=$(($num * 1024 * 1024))
    elif [ "$unit" == "M" ];then
        bt=$(($num * 1024))
    else
        bt=$size
    fi

    echo "Create swap file /swapfile ($bt) use dd command"
    sudo dd if=/dev/zero of=/swapfile bs=1024 count=$bt

    sudo chmod 600 /swapfile

    echo 'Use the mkswap utility to set up a Linux swap area on the file.'
    sudo mkswap /swapfile

    echo 'Activate the swap file /swapfile.'
    sudo swapon /swapfile

    echo 'Add the swap file entry "/swapfile swap swap defaults 0 0" to the /etc/fstab file.'
    sudo sed -i '$a/swapfile swap swap defaults 0 0' /etc/fstab

    echo 'Verify swap status'
    echo 'Using sudo swapon --show'
    sudo swapon --show

    echo 'Using free -h'
    sudo free -h
fi

if [ $(cat /proc/sys/vm/swappiness) != 10 ];then
    echo 'Adjusting the Swappiness Value.'
    sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
    sudo sed -i '$avm.swappiness=10' /etc/sysctl.conf
    sudo sysctl vm.swappiness=10
fi
