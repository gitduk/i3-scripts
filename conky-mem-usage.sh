#!/bin/bash
#=============================================================
# File Name: mem_usage.sh
# Author: kaige
# email: wdkany@qq.com
# Created Time: 2021年05月25日 星期二 18时18分47秒
#=============================================================

if [ "$(which bc)" ]; then

  # Display used, total, and percentage of memory using the free command.
  read total used <<<"$(free -m | awk '/Mem/{printf $2" "$3}')"

  # Calculate the percentage of memory used with bc.

  percent=$(echo $used $total | awk '{printf "%.1f", 100*$1/$2}')

  if [ "$(echo "$used > 1000" | bc)" -eq 1 ]; then
      printf "%sG/%s%s" "$(echo $used | awk '{printf "%.2f", $1/1024}')" $percent "%"
  else
      printf "%sM/%s%s" "$(echo $used | awk '{printf "%s", $1}')" $percent "%"
  fi


  if [ "$(echo "$percent > 80" | bc)" -eq 1 ]; then
    time=$(date +'%Y-%m-%d %H:%M:%S')
    echo "$time Memory: $percent used" | s-nail -s "Warning!" wdkany@qq.com >/dev/null 2>&1
  fi

fi
