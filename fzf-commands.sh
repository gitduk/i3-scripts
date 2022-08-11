#!/usr/bin/env bash

BUFFER=$(for path in ${PATH//:/ }; do
  [ ! -e "$path" ] && continue
  for cmd in $(find $path -maxdepth 1 -type f -follow 2>/dev/null); do
    echo $cmd
  done
done |sort|uniq|fzf --prompt="commands> " --query="${@}")

echo $BUFFER

