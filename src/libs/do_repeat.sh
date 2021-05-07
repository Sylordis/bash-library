#! /bin/bash

#------------------------------------------------------------------------------
# Repeats the same command multiple times through an eval interpretation. This
# function does not manage the errors caused by the interpreted commands and
# will not stop until it reached the correct count.
# Params:
#   $1    Number of repetitions.
#   $*    Command(s) to be repeated
#------------------------------------------------------------------------------
do_repeat() {
  # Check if first argument is a number
  if [ "$1" -eq "$1" 2> /dev/null ] && [[ $# -gt 1 ]]; then
    for _ in $(seq 1 "$1"); do
      eval "${@:2}"
    done
  fi
}
