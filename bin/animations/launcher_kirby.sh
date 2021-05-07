#! /bin/bash

source "$SH_PATH_ANIM/helpers/init_animation.sh"

args_bg=(-v)
if [[ "$1" == "-nv" ]]; then
  args_bg=()
  shift
fi

t=8
[[ -n "$1" ]] && t="$1"

$SH_PATH/launch_bg_process.sh "${args_bg[@]}" -t $t -s $SH_PATH_ANIM/src/animation_kirby.sh animation_kirby
