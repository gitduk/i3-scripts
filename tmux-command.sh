#!/bin/bash

function kill_session {
    if [ -n "$1" ];then
        session=$1
    else
        session=$(tmux display-message -p '#S')
    fi

    if [ ! -n "$(echo $session | grep -E '^\*.*\*$')" ] && [ $(tmux list-sessions | wc -l) -ge 2 ]; then
        tmux kill-session -t "$session";
    fi
}

function kill_window {
    session=$(tmux display-message -p '#S')
    window_nums=$(tmux list-windows|wc -l)

    if ([ -n "$(echo $session | grep -E '^\*.*\*$')" ] || [ $(tmux list-sessions | wc -l) -eq 1 ]) && [ $window_nums -eq 1 ]; then
        echo &> /dev/null
    else
        tmux kill-window
    fi
}

function kill_pane {
    session=$(tmux display-message -p '#S')
    pane_nums=$(tmux list-panes|wc -l)
    window_nums=$(tmux list-windows|wc -l)

    if ([ -n "$(echo $session | grep -E '^\*.*\*$')" ] || [ $(tmux list-sessions | wc -l) -eq 1 ]) && [ $window_nums -eq 1 ] && [ $pane_nums -eq 1 ]; then
        echo &> /dev/null
    else
        tmux kill-pane
    fi
}

function kill_all_session {
    sessions=$(tmux list-sessions -F '#S')
    current=$(tmux display-message -p '#S')
    for session in ${sessions[@]}; do
        if [ ! "$session" == "$current" ];then
            kill_session $session
        fi
    done
}

function kill_all_window {
    windows=$(tmux list-windows|wc -l)
    tmux swap-window -d -t 1

    for ((i=2;i<=$windows;i++)); do
        tmux kill-window -t 2
    done

}

function break_all_pane {
    tmux swap-pane -d -t 1
    panes=($(tmux list-panes -F '#{pane_index}'|wc -l)-1)
    for ((i=1;i<=$panes;i++)); do
        tmux break-pane -d -s 2
    done
}

function join_all_pane {
    hv=0
    windows=$(tmux list-windows -F '#{window_index}'|wc -l)
    tmux swap-window -d -t 1
    for ((w=2;w<=$windows;w++)); do

        if [ $(($hv % 2)) == 0 ];then
            pmt='h'
        else
            pmt='v'
        fi
        hv=$(($hv+1))

        panes=$(tmux list-panes -t 2 -F '#{pane_index}'|wc -l)
        for ((p=1;p<=$panes;p++)); do
            tmux join-pane -$pmt -s 2.$(($panes-$p+1)) &> /dev/null
        done
    done
    tmux select-pane -t 1
}

function send_to_pane {
    for w in $(tmux list-windows -F '#{window_index}'); do
        for p in $(tmux list-pane -t :$w -F '#{pane_index}'); do
            tmux send-keys -t :$w.$p "$*"
            tmux send-keys -t :$w.$p Enter
        done
    done
}

function attach_session {
    session=$(tmux list-sessions|grep -v attached|cut -d ':' -f1|sort -n|head -n 1)
    if [ -n "$session" ];then
        active_window="$(tmux list-windows -t "$session" -F '#{window_index}:#{window_active}'|grep ':1'|cut -d ':' -f1)"
        active_pane="$(tmux list-panes -t "$session:$active_window" -F '#{pane_index}:#{pane_active}'|grep ':1'|cut -d ':' -f1)"
        current_command="$(tmux display-message -p -t "$session:$active_window.$active_pane" -F '#{pane_current_command}')"

        [ "$current_command" == "zsh" ] && tmux send-keys -t "$session:$active_window.$active_pane" "clear" Enter
        tmux -2 attach -t "$session"
    else
        max_index=$(tmux list-sessions -F '#S'|tr -d '*'|grep -v -E '[a-z]'|sort -nr|head -n 1)
        for ((i=1;i<=$(($max_index+1));i++)); do
            tmux has-session -t "$i" &>/dev/null && continue
            tmux has-session -t "*$i*" &> /dev/null && continue
            tmux -2 new-session -s "$i" &> /dev/null
            [ $? -eq 0 ] && exit
        done
    fi
}

function lock_session {
    ss_name="$(tmux run-shell 'echo "#S"')"
    if [ -n "$(grep -E '^\*.*\*$' <<< "$ss_name")" ]; then
        tmux rename-session "$(tr -d '*' <<< "$ss_name")"
    else
        tmux rename-session "*$ss_name*";
    fi
}

if [ -n "$2" ];then
    $1 "${@:2}"
else
    $1
fi

