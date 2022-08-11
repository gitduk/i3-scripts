#!/usr/bin/env bash
# -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.

# File Name : services.sh

# Creation Date : 2022-05-12 11:13:59

# Last Modified : Tue 31 May 2022 04:20:51 PM CST

# Created By : wukaige

# Description : show system services status

# _._._._._._._._._._._._._._._._._._._._._.

source $HOME/.fzf.zsh &>/dev/null

FZF_COMMAND="$HOME/.fzf/bin/fzf $FZF_OPTS"

while read -r line
do
  sname=`awk '{printf $1}' <<< $line`
  [[ "$sname" == "\x26.service" ]] && continue
  if [[ "$(systemctl is-active ${sname//@/})" == "inactive" ]]; then
   printf "${line/$sname/" $sname"}\n"
  else
   printf "${line/$sname/"  $sname"}\n"
  fi
done <<< $(systemctl list-unit-files --no-pager --type=service --no-legend) | tr -d '\\' | $FZF_COMMAND
