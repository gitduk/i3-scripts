#!/usr/bin/env bash

history=$HOME/.trans.history

if ! hash trans &>/dev/null; then
  echo '\`trans\` command not found'
  exit 1
fi

query="Trans History
---------------------
""$(tac $history)"

read option w <<< "$(fzf -e --print-query <<< $query | head -n 1)"

if [[ ! -z "$option" ]]; then
  if [[ $option == "z" ]]; then
    urxvt -title floating -e /usr/bin/zsh -c "trans -show-languages no "$w" | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | fzf -e"
  else
    urxvt -title floating -e /usr/bin/zsh -c "trans -show-languages no :zh "$option" | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | fzf -e --bind 'ctrl-i:execute(echo $option '{}' >> $history)+abort'"
  fi
fi
