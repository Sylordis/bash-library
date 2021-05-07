#! /bin/bash

source "$SH_PATH_ANIM/helpers/init_animation.sh"

args=(30)
t=8
if [[ "$1" == "full" ]]; then
  args=()
fi
$SH_PATH/launch_bg_process.sh -v -t $t -s $SH_PATH_ANIM/src/animation_fish.sh animation_fish "${args[@]}"
