#!/usr/bin/env bash

url=https://v2.jinrishici.com/sentence
token=H9LSRAntF59XFFig567BRfgxxYUoks88


function rofi-poem() {
  [ ! -e "/tmp/poem" ] && curl -s $url -H "X-User-Token:$token" > /tmp/poem
  content=$(cat /tmp/poem|jq .data.origin|grep -E '",$|"$'| awk -F ':' '{print $NF}'|tr -d '",'|sed -n 's/ *//p'|sed -n '2N;s/\n/ - /;2!p')

  theme='window {location: center; width: 50%; height: 50%;} element-text {horizontal-align: 0.5;}'
  prompt=$(cat /tmp/poem|jq .data.matchTags|grep '"'|tr -d '",'|sed ':a;s/ *//g;N;s/\n/-/;t a')

  result=$(rofi -p $prompt -dmenu -theme-str "$theme"  <<< $content)

  [ -n "$result" ] && echo \"$result\"
}

case $1 in
  show)
    rofi-poem
    ;;
  update)
    curl -s $url -H "X-User-Token:$token" | tee /tmp/poem
    ;;
  *)
    exit 1
esac


