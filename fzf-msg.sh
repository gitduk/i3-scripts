#!/usr/bin/env bash

head="$1"
msg="$2"
if [ -z "$2" ]; then
  head="msg"
  msg="$1"
fi


urxvt -title floating -e /usr/bin/zsh -c "printf '$msg'|fzf --prompt='$head> '"
