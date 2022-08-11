#!/bin/bash
#=============================================================
# File Name: load_avg.sh
# Author: kaige
# email: wdkany@qq.com
# Created Time: 2021年05月25日 星期二 18时07分43秒
#=============================================================

core_num=$(grep -c 'model name' /proc/cpuinfo)
avg_1=$(cat /proc/loadavg | cut -d ' ' -f1)
avg_5=$(cat /proc/loadavg | cut -d ' ' -f2)
avg_15=$(cat /proc/loadavg | cut -d ' ' -f3)

printf "%s" "$avg_1/$avg_5/$avg_15"
