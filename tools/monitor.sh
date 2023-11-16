#! /usr/bin/env bash

# This script allows to monitor several processes, i.e. launching a top process for the processes id corresponding to the processes names.
# This basically links a pgrep search to a top process with a bit of error control.
# Dependencies: pgrep, top

#------------------------------------------------------------------------------
# Displays basic usage
#------------------------------------------------------------------------------
usage() {
  echo "Usage: $(basename "$0") <ps..>"
}

# Argument checks
if [[ $# -eq 0 ]]; then
  echo "ERROR: Wrong number of arguments." >& 2
  usage
  exit 1
fi

# Launch command
top -d 2 -p "$(pgrep -d , "$@")" 2> /dev/null || { echo "INFO: Given processes do not exist."; exit 1; }
