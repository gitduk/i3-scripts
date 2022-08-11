#!/usr/bin/env bash

msg="$1"

source $HOME/.fzf.zsh &>/dev/null

function main_page() {
  echo "# ___ containers ___"
  echo "$(docker container ls -a)"
  echo
  echo "# ___ images ___"
  echo "$(docker image ls -a)"
}

read cid image name stat size <<< "$(echo "`main_page`" | fzf --bind="ctrl-r:reload:echo '# === containers ===' && docker container ls && echo && echo '# === images ===' && docker image ls")"

[ -z $cid ] && exit 0

if [ -n "$(grep -Ew '\s[0-9]{1,}\.?[0-9]{1,}[MKG]B$' <<< "$size")" ]; then
  options="1 remove"
  read option o <<< "$(fzf --prompt="image> " <<< $options)"
  case "$option" in
    1) docker image rm $name | fzf --prompt="rm> " ;;
  esac
else
  if [ $cid != '#' ]; then
    options="1 start\n2 restart\n3 stop\n4 remove\n5 inspect"

    read option o <<< "$(printf "$options" | fzf --prompt="container> ")"
    case "$option" in
      1) docker container start $cid | fzf --prompt="start> " ;;
      2) docker container restart $cid | fzf --prompt="restart> " ;;
      3) docker container stop $cid | fzf --prompt="stop> " ;;
      4) docker container rm $cid | fzf --prompt="rm> " ;;
      5) docker inspect $cid | fzf --prompt="inspect> " ;;
    esac
  fi
fi

bash $HOME/.bin/fzf-docker.sh
