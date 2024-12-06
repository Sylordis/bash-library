#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Outputs a message to the terminal if its log level is greater or equal to the
# currently set global log level.
# Global log level is defined by variable LOGLEVEL, which defaults to 1.
# Params:
#  [$1]   Log level to output this log message for.
#   $*    Options for echo and message to output.
#------------------------------------------------------------------------------
log_for_level() {
  local loglevel=1
  if [[ "$(echo -e "$@" | sed -r "s:\x1B\[[0-9;]*[mK]::g")" =~ [0-9]+ ]]; then
    loglevel="$1"
    shift
  fi
  if [[ ${LOGLEVEL-1} -le "$loglevel" ]]; then
    echo "$@"
  fi
}
logl() { log_for_level "$@"; }
