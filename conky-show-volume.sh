#!/bin/bash
#=============================================================
# File Name: show_volume.sh
# Author: kaige
# email: wdkany@qq.com
# Created Time: 2021年05月25日 星期二 18时57分20秒
#=============================================================

pulsemixer --get-volume|cut -d " " -f1
