#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Displays a dancing kirby.
# Options:
#   -pid <PID>  PID of the program to wait for
# Dependencies:
#   awk, echo, grep, printf, sleep
#------------------------------------------------------------------------------
animation_kirby() {
  local curr pause pid
  curr=0
  animation_size=10
  kirby=("(>^-^)>" "<(^-^)>" "<(^-^<)" "^(^-^)^" "<(^-^)>" "v(^-^)v" "<(^-^)>" \
         " <(^-^)>" "<(^-^)>" "\b<(^-^)>" "<(^-^)>")
  pause=0.5
  while : ; do
    case "$1" in
      -pid) shift; pid="$1";;
         *) break;;
    esac
    shift
  done
  while [[ -z "$pid" ]] || grep -q "$pid" <<< "$(ps -ef | awk '{print $2}')"; do
    echo -en "$(printf " %-${animation_size}s" "${kirby[$curr]}")\r"
    ((curr++))
    [[ $curr -ge ${#kirby[@]} ]] && curr=0
    sleep $pause
  done
}
