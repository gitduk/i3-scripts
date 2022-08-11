#!/usr/bin/env bash

# ___ env ___
export NETWORK_INTERFACE="$(ip route show default | awk '{print $5}' | head -n 1)"
export ESSID="$(iwconfig 2>/dev/null| grep ESSID | awk -F '"' '{print $2}')"

if [[ ! -n "$NETWORK_INTERFACE" ]]; then
  export NETWORK_INTERFACE=$(ip link show | grep -o -e "eno[1-9]")
  export NETWORK_INTERFACE=$(ip link show | grep -o -e "wlan[1-9]")
fi

if [[ "$NETWORK_INTERFACE" = *wlan* ]]; then
  export CONNECTED_TYPE="直 $ESSID:"
  export DISCONNECTED_TYPE="睊 $ESSID:"
else
  export CONNECTED_TYPE="說"
  export DISCONNECTED_TYPE="ﲁ"
fi

if hash xrandr; then
  export OUTPUT="$(xrandr 2>/dev/null|grep '\sconnected'|awk '{printf $1}')"
fi

if [[ -n "$(ls /sys/class/hwmon/hwmon*)" ]]; then
  for i in /sys/class/hwmon/hwmon*/temp*_input; do
    if [ "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*}))" = "coretemp: Core 0" ]; then
        export HWMON_PATH="$i"
    fi
  done
fi

# ___ launch theme ___
dir="$HOME/.config/polybar"
pushd $dir &>/dev/null
themes=(`find -L * -maxdepth 0 -type d`)
popd
rofi_theme='window {location: northwest; width: 15em; height: 20em; x-offset: 3; y-offset: 30;} element-text {horizontal-align: 0;}'

launch_bar() {
  style="$1"
	# Terminate already running bar instances
	pidof polybar && pkill polybar
  killall -q polybar

	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

	# Launch the bar
	if [[ "$style" == "one-dark" || "$style" == "hack" ]]; then
		polybar -q top -c "$dir/$style/config.ini" &
		polybar -q bottom -c "$dir/$style/config.ini" &
	else
		polybar -q main -c "$dir/$style/config.ini" &
	fi
}

if [[ -n "$1" ]]; then
	style="${1/--/}"
  for theme in "${themes[@]}"
  do
    if [ "$style" == "$theme" ];then
      launch_bar $style
      exit 0
    fi
  done
  cat <<- EOF
Usage : launch.sh --theme

Available Themes :

`echo ${themes[@]}|xargs -n 4|awk '{printf "%-15s %-15s %-15s %-15s\n", $1,$2,$3,$4}'`

EOF
  exit 1
else
  style=$(echo ${themes[@]}|xargs -n 1|rofi -dmenu -theme-str "$rofi_theme"  -p 'themes')
  [ -n "$style" ] && launch_bar $style
fi

