#!/bin/bash
#=============================================================
# File Name: net_speed.sh
# Author: kaige
# email: wdkany@qq.com
# Created Time: 2021年05月25日 星期二 16时54分56秒
#=============================================================

ssid=$(iwgetid -r)

up_start=$(cat /proc/net/dev | tail -n 1 | cut -d ':' -f 2 | awk -F ' ' '{printf "%.2f", $9/1024}')
down_start=$(cat /proc/net/dev | tail -n 1 | cut -d ':' -f 2 | awk -F ' ' '{printf "%.2f", $1/1024}')
sleep 1
up_end=$(cat /proc/net/dev | tail -n 1 | cut -d ':' -f 2 | awk -F ' ' '{printf "%.2f", $9/1024}')
down_end=$(cat /proc/net/dev | tail -n 1 | cut -d ':' -f 2 | awk -F ' ' '{printf "%.2f", $1/1024}')

up_speed=$(echo $up_end $up_start | awk '{printf "%.2f", $1-$2}')
down_speed=$(echo $down_end $down_start | awk '{printf "%.2f", $1-$2}')

if [ "$(echo "$up_speed > 1024" | bc)" == 1 ]; then
  up_speed=$(echo $up_speed | awk '{ printf "%.2f ms", $1/1024}')
else
  up_speed=$(printf "%.2f ks" $up_speed)
fi

if [ "$(echo "$down_speed > 1024" | bc)" == 1 ]; then
  down_speed=$(echo $down_speed | awk '{ printf "%.2f ms", $1/1024}')
else
  down_speed=$(printf "%.2f ks" $down_speed)
fi

if [ $ssid ]; then
    printf "%s %s   %s" "⇡ $up_speed" "⇣ $down_speed" "$ssid"
else
    printf "%s %s" "⇡ $up_speed" "⇣ $down_speed"
fi
