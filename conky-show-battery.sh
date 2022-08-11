#!/bin/bash
#=============================================================
# File Name: show_battery.sh
# Author: kaige
# email: wdkany@qq.com
# Created Time: 2021年05月25日 星期二 23时33分30秒
#=============================================================

if [ "$(which acpi)" ]; then
  if [ "$(cat /sys/class/power_supply/AC/online)" == 1 ]; then
    charging='☀'
  else
    charging=''
  fi

  # Check for existence of a battery.
  if [ -x /sys/class/power_supply/BAT0 ]; then
    batt0=$(acpi -b 2>/dev/null | awk '/Battery 0/{print $4}' | cut -d, -f1)
    # Display the percentage of charge the battery has.
    printf "%s " "${charging} ${batt0}"

  fi
fi
