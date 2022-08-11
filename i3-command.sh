#!/bin/bash

function unlock {
  if [ "$1" == " " ]; then
    i3-msg mode "default"
  fi
}

function cbg {
  mv -f /tmp/bg /tmp/bg.pre &> /dev/null
  download_picsum
  feh --bg-scale "/tmp/bg"
  python $HOME/.bin/change_foreground.py
}

function download_picsum() {
  aria2c "https://picsum.photos/1920/1080" -d "/tmp" -o "bg"
}

function check {
  requires=(picom feh pulsemixer bc xrandr notify-send rofi conky s-nail)

  for r in ${requires[*]}; do
    if ! command -v $r &> /dev/null
    then
      if command -v notify-send &> /dev/null
      then
        notify-send "i3 health warning" "'$r' command could not be found."
      fi
      echo "'$r' command could not be found." >> $HOME/i3-heath-warning.txt
    fi
  done

  ipaddress="$(curl cip.cc 2>/dev/null |grep IP|cut -d ':' -f 2|tr -d ' ')"
  if [ -n "$ipaddress" ];then
    echo $ipaddress > /tmp/publicip
  fi
}

if [ -n "$2" ];then
    $1 "${@:2}"
else
    $1
fi

