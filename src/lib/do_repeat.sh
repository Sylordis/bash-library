#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Repeats the same command multiple times through an eval interpretation. This
# function does not manage the errors caused by the interpreted commands and
# will not stop until it reached the correct count.
# Params:
#   $1    <n> Number of repetitions.
#   $*    <cmd> Command to be repeated
# Dependencies:
#   seq
#------------------------------------------------------------------------------
do_repeat() {
  # Check if first argument is a number
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    for _ in $(seq 1 "$1"); do
      eval "${@:2}"
    done
  fi
}
