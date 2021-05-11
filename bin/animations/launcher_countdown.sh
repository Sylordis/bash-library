#! /usr/bin/env bash

source "$SH_PATH_UTILS/init_animation.sh"
source "$SH_PATH_ANIM/animation_countdown.sh"

animation_countdown "${@-5}"
