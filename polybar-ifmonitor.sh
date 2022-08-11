#!/bin/env bash

export IFNAME="$(ifconfig |grep -i running|grep -v lo|awk -F ':' '{print $1}')"
export ESSID=$(iwconfig 2>/dev/null |grep ESSID|cut -d ':' -f2|tr -d '"')

if [ ! -n "$ESSID" ];then
    export ESSID="ETHERNET"
fi

