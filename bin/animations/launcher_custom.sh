#! /usr/bin/env bash

source "$SH_PATH_UTILS/init_animation.sh"

args_bg=(-v)
t=8
while : ; do
  case "$1" in
    -nv) args_bg=();;
     -t) t="$2"; shift;;
      *) break;;
  esac
  shift
done
if [[ $# -eq 0 ]]; then
  args=(-m "% There's a secret [%ANIM%] among the living" hello this is dog)
else
  args=("$@")
fi
"$SH_PATH/tools/launch_bg_process.sh" "${args_bg[@]}" -t "$t" \
    -s "$SH_PATH_ANIM/animation_custom.sh" \
    animation_custom "${args[@]}"
