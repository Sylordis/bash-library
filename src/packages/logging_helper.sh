#! /usr/bin/env bash

#------------------------------------------------------------------------------
# logging_helper.log()
# Outputs a log message.
# Params:
#   $*    Message to log
# Options:
#   -l <L>  Outputs a log with given level L. Level should not be more than
#           5 characters.
#------------------------------------------------------------------------------
log() {
  if [[ "$1" == "-l" ]]; then
    echo -n "[$(printf "%-5s" "$2")] "
    shift 2
  fi
  echo -e "$@"
}

#------------------------------------------------------------------------------
# logging_helper.log_debug()
# Logs a message with DEBUG level.
# Options:
#   -u    makes the output uncatchable.
#------------------------------------------------------------------------------
log_debug() {
  if [[ "$1" == "-u" ]]; then
    shift
    log -l "DEBUG" "$@" > /dev/tty
  else
    log -l "DEBUG" "$@"
  fi
}

#------------------------------------------------------------------------------
# logging_helper.log_error()
# Logs a message with ERROR level.
#------------------------------------------------------------------------------
log_error() {
  log -l "ERROR" "$@" >& 2
}

#------------------------------------------------------------------------------
# logging_helper.log_info()
# Logs a message with INFO level.
#------------------------------------------------------------------------------
log_info() {
  log -l "INFO" "$@"
}

#------------------------------------------------------------------------------
# logging_helper.log_warn()
# Logs a message with WARN level.
#------------------------------------------------------------------------------
log_warn() {
  log -l "WARN" "$@"
}
