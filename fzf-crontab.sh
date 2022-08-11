#!/usr/bin/env bash

source $HOME/.fzf.zsh &>/dev/null
FZF_COMMAND="$HOME/.fzf/bin/fzf $FZF_OPTS"
PP="$HOME/.bin/pp"

task=$(while read -r line
do
  line=${line//\*/\\*}
  echo $line | sed -n 's/\\\*/*/g;p'
done <<< $(crontab -l | grep -Ev "^#|^$|^[a-zA-Z]") | sort | $FZF_COMMAND)

read _ _ _ _ _ command <<< $task
[[ -z "$command" ]] && exit 0

$PP --cmd "$command" | $FZF_COMMAND

