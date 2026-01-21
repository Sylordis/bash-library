#! /usr/bin/env bash

source "$SH_PATH_UTILS/init_animation.sh"

args_bg=()
if [[ "$1" == "-v" ]]; then
  args_bg=(-v)
  shift
fi

t=8
[[ -n "$1" ]] && t="$1"

"$SH_PATH/tools/launch_bg_process.sh" "${args_bg[@]}" -t "$t" \
    -s "$SH_PATH_ANIM/animation_kirby.sh" \
    animation_kirby
