#! /bin/bash

source "$SH_PATH_ANIM/helpers/init_animation.sh"

t=3
args=()
if [[ $# -ne 0 ]]; then
  args=(-m "$@")
  have_bar=1
  for arg; do
    [[ "$arg" == *"%BAR%"* ]] && have_bar=0
  done
  if [[ $have_bar -eq 1 ]]; then
    echo "ERROR: you need '%BAR%' string in your message." >& 2
    exit 1
  fi
fi
$SH_PATH/launch_bg_process.sh -v -t $t -s $SH_PATH_ANIM/src/animation_spinner.sh animation_spinner "${args[@]}"
