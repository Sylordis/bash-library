#! /bin/bash

#------------------------------------------------------------------------------
# animation_ping_pong()
# Displays an animated ball.
# Params:
#  [$1]   PID of process to wait on
#------------------------------------------------------------------------------
animation_ping_pong() {
  local pause="0.25"
  # Characters used for the spinner in order
  local chars='⚬⚪⦾⚪⚬'
  local direction=1
  local i=0
  # Real spinning part
  while [[ -z "$1" ]] || grep -q "$1" <<< "$(ps -ef | awk '{print $2}')"; do
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
