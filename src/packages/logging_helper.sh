#! /usr/bin/env bash

# This package provides different methods to ouput messages in a harmonised way
# on different standard streams:
#   "[LEVEL] <Message>" if a level is set, just the message otherwise.
#
# The methods are mapped to usual logger levels:
#   log_debug, log_info, log_warn, log_error
#
# It does not manage log levels and each method will output something.

#------------------------------------------------------------------------------
# logging_helper.log()
# Outputs a log message.
# Params:
#   $*    Message to log
# Options:
#   -l <L>  Outputs a log with given level L. Level should not be more than
#           5 characters.
# Dependencies:
#   echo, printf
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
#   -u    makes the output uncatchable by outputting on /dev/tty
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
# Logs a message with ERROR level on stderr.
#------------------------------------------------------------------------------
log_error() {
  log -l "ERROR" "$@" >& 2
}

#------------------------------------------------------------------------------
# logging_helper.log_info()
# Logs a message with INFO level on std.
#------------------------------------------------------------------------------
log_info() {
  log -l "INFO" "$@"
}

#------------------------------------------------------------------------------
# logging_helper.log_warn()
# Logs a message with WARN level on std.
#------------------------------------------------------------------------------
log_warn() {
  log -l "WARN" "$@"
}
