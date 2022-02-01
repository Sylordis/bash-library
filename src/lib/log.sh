#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Prints a message on a particular stream using `echo -e` and according to provided
# configuration. This method accepts only one option per call.
# Params:
#   $*    Messages to log.
# Options:
#   -d    Logs the message on to /dev/tty.
#   -e    Logs the message to error stream.
#   -v    Logs the message only if VERBOSE_MODE is set to 0.
#------------------------------------------------------------------------------
log() {
  local _stream=1
  case "$1" in
    -d) _stream='/dev/tty'
        shift;;
    -e) _stream=2
        shift;;
    -v) [[ ${VERBOSE_MODE-1} -ne 0 ]] && return 0
        shift;;
  esac
  echo -e "$@" >& $_stream
}
