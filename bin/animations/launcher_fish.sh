#! /usr/bin/env bash

source "$SH_PATH_UTILS/init_animation.sh"

args_bg=(-v)
args=(20)
t=8
while : ; do
  case "$1" in
    -nv) args_bg=();;
   full) args=();;
     -t) t="$2"; shift;;
      *) break;;
  esac
  shift
done
"$SH_PATH/tools/launch_bg_process.sh" "${args_bg[@]}" -t "$t" \
    -s "$SH_PATH_ANIM/animation_fish.sh" \
    animation_fish "${args[@]}"
