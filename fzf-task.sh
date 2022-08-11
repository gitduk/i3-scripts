#!/usr/bin/env bash

if ! hash task &>/dev/null; then
  echo '\`task\` command not found'
  exit 1
fi

options="$(task next|sed '1d;$d')""

Options
---------------------
1 add task
2 mark task done
3 delete task
4 list completed task
5 list all task
? help
"

read option tskd <<< "$(fzf -e --print-query <<< $options | sed '/^$/d'| head -n 1)"

if [[ -n "$(grep -E '[0-9]{1,2}[mhds](in)?' <<< $tskd)" ]]; then
  task $option done
  option=""
  bash $HOME/.bin/fzf-task.sh
fi

case $option in
  1)
    doc="task pri:H/M/L
ta  sk +tag1 +tag2"
    tsk="$(fzf -e --print-query <<< $doc | head -n 1)"
    if [[ -n "$tsk" ]]; then
      task add $tsk
    fi
    ;;
  add) task add "$tskd" && echo "$tskd" > ~/t ;;
  2)
    tsk_id="$(task next | fzf -e | cut -d ' ' -f2 | grep -E '[0-9]{1,}')"
    if [[ -n "$tsk_id" ]]; then
      task $tsk_id done
    fi
    ;;
  done) task done $tskd ;;
  3)
    tsk_id="$(task next | fzf -e | cut -d ' ' -f2 | grep -E '[0-9]{1,}')"
    if [[ -n "$tsk_id" ]]; then
      task $tsk_id delete
    fi
    ;;
  del) task delete $tskd ;;
  4)
    task all status:completed | fzf -e
    ;;
  ls) task all status:completed | fzf -e ;;
  5)
    task all | fzf -e
    ;;
  la) task all | fzf -e ;;
  \?) man task | fzf -e ;;
  *) exit 1 ;;
esac
[[ -z "$option" ]] && [[ -z "$tskd" ]] && exit 0 || bash $HOME/.bin/fzf-task.sh
