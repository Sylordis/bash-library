#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Checks if the provided dependencies are on the system, using the 'command'
# binary (should be built-in).
# Options:
#   -w
#   -w=[msg]
#             Prints a message on the error stream if the binary could not be
#             found. A custom message can be specified, use pattern '__BIN__'
#             for the name of the dependency.
# Args:
#   $*    All dependencies to be checked
#------------------------------------------------------------------------------
check_dependencies() {
  local dependency error_msg ps_ret=0
  while : ; do
    case "$1" in
      -w) error_msg="ERROR: cannot find dependency '__BIN__' on the system.";;
      -w=*) error_msg="${1#-w=}";;
      *) break;;
    esac
    shift
  done
  for dependency in "$@"; do
    if ! command -v "${dependency}" > /dev/null; then
      [[ -n "$error_msg" ]] && \
        echo -e "${error_msg//'__BIN__'/"$dependency"}" >& 2
      ps_ret=1
    fi
  done
  return $ps_ret
}
