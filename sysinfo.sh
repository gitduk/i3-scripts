#!/bin/bash

function core_sensor() {
  echo ""
  sensors | grep Core | tr -d "+" | awk '{printf "\t\033[31m%s%s\033[0m %s ", $1,$2,$3}'
}

# mem use
function memory_usage() {
  if [ "$(which bc)" ]; then
    # Display used, total, and percentage of memory using the free command.
    read total used <<<"$(free -m | awk '/Mem/{printf $2" "$3}')"

    # Calculate the percentage of memory used with bc.

    percent=$(echo $used $total | awk '{printf "%.1f", 100*$1/$2}')

    if [ "$(echo "$used > 1000" | bc)" -eq 1 ]; then
      printf "Mem Usage: %sG/%s%s\n" "$(echo $used | awk '{printf "%.2f", $1/1024}')" $percent "%"
    else
      printf "Mem Usage: %sM/%s%s\n" "$(echo $used | awk '{printf "%s", $1}')" $percent "%"
    fi

    if [ "$(echo "$percent > 80" | bc)" -eq 1 ]; then
      time=$(date +'%Y-%m-%d %H:%M:%S')
      echo "$time Memory: $percent used" | s-nail -s "Warning!" wdkany@qq.com >/dev/null 2>&1
    fi
  fi
}

function load_average() {
  avg_1=$(cat /proc/loadavg | cut -d ' ' -f1)
  avg_5=$(cat /proc/loadavg | cut -d ' ' -f2)
  avg_15=$(cat /proc/loadavg | cut -d ' ' -f3)

  printf "CPU Avg: %s\n" "$avg_1 $avg_5 $avg_15"

}

function ip_address() {

  local address
  local host

  # Loop through the interfaces and check for the interface that is up.
  for file in /sys/class/net/*; do

    iface=$(basename $file)

    read status <$file/operstate

    [ "$status" == "up" ] && address=$(ip addr show $iface | awk '/inet /{printf $2}')

    [ "$status" == "up" ] || address="No internet address"

  done

  printf "IP Address: %s\n" "$address"

}

function proxy_info() {
  proxy=$(ss -lntp |grep privoxy|awk -F ' ' '{printf  $4}')

  if [ "$proxy" ]; then
    echo "Proxy: $proxy"
  else
    echo "No proxy"
  fi
}

function battery_meter() {
  if [ "$(which acpi)" ]; then
    if [ "$(cat /sys/class/power_supply/AC/online)" == 1 ]; then
      local charging='+'
    else
      local charging='-'
    fi

    # Check for existence of a battery.
    if [ -x /sys/class/power_supply/BAT0 ]; then
      batt0=$(acpi -b 2>/dev/null | awk '/Battery 0/{print $4}' | cut -d, -f1)
      # Display the percentage of charge the battery has.
      printf "Battery: %s\n" "${charging} ${batt0}"
    fi
  else
    printf "Battery: %s\n" "No battery"
  fi
}

function net_speed() {
  local up_start
  local down_start
  local up_end
  local down_end
  local up_speed
  local down_speed

  up_start=$(cat /proc/net/dev | tail -n 1 | cut -d ':' -f 2 | awk -F ' ' '{printf "%.2f", $9/1024}')
  down_start=$(cat /proc/net/dev | tail -n 1 | cut -d ':' -f 2 | awk -F ' ' '{printf "%.2f", $1/1024}')
  sleep 1
  up_end=$(cat /proc/net/dev | tail -n 1 | cut -d ':' -f 2 | awk -F ' ' '{printf "%.2f", $9/1024}')
  down_end=$(cat /proc/net/dev | tail -n 1 | cut -d ':' -f 2 | awk -F ' ' '{printf "%.2f", $1/1024}')

  up_speed=$(echo $up_end $up_start | awk '{printf "%.2f", $1-$2}')
  down_speed=$(echo $down_end $down_start | awk '{printf "%.2f", $1-$2}')

  if [ "$(echo "$up_speed > 1024" | bc)" == 1 ]; then
    up_speed=$(echo $up_speed | awk '{ printf "%.2f ms", $1/1024}')
  else
    up_speed=$(printf "%.2f ks" $up_speed)
  fi

  if [ "$(echo "$down_speed > 1024" | bc)" == 1 ]; then
    down_speed=$(echo $down_speed | awk '{ printf "%.2f ms", $1/1024}')
  else
    down_speed=$(printf "%.2f ks" $down_speed)
  fi

  printf "Net Speed: %s %s" "⇡ $up_speed" "⇣ $down_speed"

}

function hw() {
  # CPU
  lshw -C processor  2>/dev/null | grep "\-cpu$" -A 3
  # 显卡
  lshw -C display  2>/dev/null | grep "\-display$" -A 3
  # 声卡
  lshw -C  multimedia  2>/dev/null | grep "\-multimedia" -A 3
  # 网卡
  lshw -C  network  2>/dev/null | grep "\-network$" -A 3
}

function monitor() {
  xrandr -q | head -n 3
}

function device() {
  echo ""
  df | head -n 1
  df | grep "^/dev" | sort
}

$1
