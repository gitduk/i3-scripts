#!/bin/env bash

# aria2c "https://picsum.photos/1920/1080" -d "/tmp" -o "bg"

function bing {
  # 1366 1920 3840
  resolution=3840
  resp=$(curl "https://bing.biturl.top/?resolution=$resolution&format=json&index=random&mkt=random")
  url=$(jq .url <<< $resp)
  name=$(jq .copyright <<< $resp)
  name=${name//\"/}
  name=${name%%\(*}
  name=${name%%,*}
  name="$(echo $name)"
  img_path="$HOME/Pictures/wallpaper/$name.jpg"
  if [[ ! -e "$img_path" ]]; then
    aria2c ${url//\"/} -d "$HOME/Pictures/wallpaper" -o "$name.jpg"
  fi
  feh --bg-scale "$img_path"
}

function picsum() {
  aria2c "https://picsum.photos/1920/1080" -d "/tmp" -o "bg"
}

# ==============================================================================
# ___ args ___
function usage() {
  cat <<- EOF
i3-change-bg:

-b --bing
-p --picsum
EOF
}


short="b,p"
long="bing,picsum"
ARGS=`getopt -a -o $short -l $long -n "i3-change-bg" -- "$@"`

[ $? -ne 0 ] && usage
eval set -- "${ARGS}"

while true
do
  case "$1" in
  -b|--bing) bing ;;
  -p|--picsum) picsum ;;
  --) shift ; break ;;
  esac
shift
done
