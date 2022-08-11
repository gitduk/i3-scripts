#!/usr/bin/env bash

source $HOME/.fzf.zsh &>/dev/null
FZF_COMMAND="$HOME/.fzf/bin/fzf $FZF_OPTS"

function show_message {
  # 系统信息
  echo "Operating System: `uname -o`"
  echo "Kernel Release: `uname -r`"
  echo "Kernel Version: `uname -v`"
  echo "Hardware Platform: `uname -i`"

  echo "Hardware Info:"
  # CPU
  lshw -C processor  2>/dev/null | grep "\-cpu$" -A 3
  # 显卡
  lshw -C display  2>/dev/null | grep "\-display$" -A 3
  # 声卡
  lshw -C  multimedia  2>/dev/null | grep "\-multimedia" -A 3
  # 网卡
  lshw -C  network  2>/dev/null | grep "\-network$" -A 3
}

show_message | $FZF_COMMAND
