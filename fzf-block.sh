#!/usr/bin/env bash

source $HOME/.fzf.zsh &>/dev/null

block_file=$HOME/.smartdns/block.conf

readarray -t domain <<< "`cat $block_file | grep -v '^#' | fzf --print-query --bind 'R:execute(sudo systemctl restart smartdns.service)'`"

domain="${domain[0]}"
selected="${domain[1]}"

[[ -z "$domain" ]] && [[ -z "$selected" ]] && exit

function add_rule {
  if [[ "$1" == *- ]]; then
    echo "address /${1%-}/-" >> $block_file
  else
    echo "address /$1/#" >> $block_file
  fi
}

function delete_rule {
  sed -i "/${1//\//\\/}/d" $block_file
}

if [[ -z "$selected" ]]; then
  add_rule "$domain"
else
  delete_rule "$selected"
fi

bash $HOME/.bin/fzf-block.sh
