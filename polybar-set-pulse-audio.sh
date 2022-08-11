#!/bin/env bash

card_name=$(pacmd list-cards | grep 'name:' |tr -d '<>'|awk '{print $2}')
output=$(pacmd list-cards| grep '[^-<]output:'| awk -F ':' '{printf "%-25s %s\n", $2, $3}' |rofi -dmenu -q "=== Audio ===")
output_name=$(awk '{print $1}' <<< $output)
pactl set-card-profile $card_name output:$output_name
