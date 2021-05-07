#! /bin/bash

source "$SH_PATH_ANIM/helpers/init_animation.sh"

args=(50)
t=8

if [[ "$1" == "full" ]]; then
  args=(-p "0.01")
fi
$SH_PATH/launch_bg_process.sh -v -t $t -s $SH_PATH_ANIM/src/animation_moving_bar.sh animation_moving_bar -f '(#-)' "${args[@]}"
