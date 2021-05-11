#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Displays a countdown.
# Params:
#   $1    <start> Starting number of the countdown
# Options:
#   -n    Display a new line at the end of the countdown.
#   -d V  Delay between two counts
#------------------------------------------------------------------------------
animation_countdown() {
  local option_newline=0 option_delay=0.25
  # Set options
  while :; do
    case "$1" in
      -d) option_delay=$2; shift;;
      -n) option_newline=1;;
       *) break;;
    esac
    shift
  done
  # Check first argument
  local error_set=1
  if [[ $# -lt 1 ]]; then
    echo "ERROR[$FUNCNAME]: No starting number specified." >& 2
    error_set=0
  elif grep -qE '[^0-9]' <<< "$1"; then
    echo "ERROR[$FUNCNAME]: Starting number not a number." >& 2
    error_set=0
  fi
  # Check delay option
  if ! grep -qE '^[0-9]+([,.][0-9]+)?$' <<< "$option_delay"; then
    echo "ERROR[$FUNCNAME]: Provided delay not a number." >& 2
    error_set=0
  fi
  [[ $error_set -eq 0 ]] && return 1
  # Proceed
  local max="$1"
  for i in $(seq $max -1 0); do
    printf "%-${#max}i" "$i"
    echo -en "\r"
    sleep $option_delay
  done
  [[ $option_newline -eq 0 ]] || echo
}
