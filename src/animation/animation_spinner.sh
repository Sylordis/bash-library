#! /usr/bin/env bash

#------------------------------------------------------------------------------
# animation_spinner()
# Displays an animated rotating bar, meant to be launched as subprocess.
# This animation is performed on a single line and does not echo a new line
# when killed, but goes back one character each time.
# Params:
#  [$1]   PID of process to wait on
# Options:
#   -m <V>   Message to display instead of just the rotating bar
#             Use pattern %BAR% for the emplacement of the spinner.
#   -p <T>   Duration between each rotation change (default 0.25)
# Dependencies:
#   awk, echo, grep, sleep
#------------------------------------------------------------------------------
animation_spinner() {
  local pause="0.25"
  local msg="%BAR%"
  # Option parsing
  while : ; do
    case "$1" in
      -m) msg="$2"; shift;;
      -t) pause="$2"; shift;;
       *) break;;
    esac
    shift
  done
  # Characters used for the spinner in order
  local chars='/-\|'
  # Real spinning part
  while [[ -z "$1" ]] || grep -q "$1" <<< "$(ps -ef | awk '{print $2}')"; do
    for (( i=0; i<${#chars}; i++ )); do
      sleep "$pause"
      echo -en "${msg//%BAR%/${chars:$i:1}}" "\r"
    done
  done
}
