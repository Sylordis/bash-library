#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Displays an animated ball.
# Options:
#   -pid <PID>  PID of the program to wait for
#------------------------------------------------------------------------------
animation_ping_pong() {
  # Characters used for the spinner in order
  local chars='○◎◯◎○'
  local direction=1 i=0 pause="0.25"
  local pid
  # Options check
  while : ; do
    case "$1" in
      -pid) pid="$2"; shift;;
         *) break;;
    esac
    shift
  done
  # Real spinning part
  while [[ -z "$pid" ]] || grep -q "$pid" <<< "$(ps -ef | awk '{print $2}')"; do
    printf "%${i}s%1s%$((${#chars}-i-1))s\r" "" "${chars:i:1}" ""
    if [[ "$direction" -eq 1 ]] && [[ $i -ge $((${#chars}-1)) ]]; then
      direction=-1
    elif [[ "$direction" -eq -1 ]] && [[ $i -le 0 ]]; then
      direction=1
    fi
    i=$((i+direction))
    sleep $pause
  done
}
