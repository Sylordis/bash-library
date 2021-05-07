#! /bin/bash

source "$SH_PATH_ANIM/helpers/init_animation.sh"

$SH_PATH/launch_bg_process.sh -v -t 8 -s $SH_PATH_ANIM/src/animation_ping_pong.sh animation_ping_pong
