#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Prints an operation result.
# Options:
#   -0 <MSG>     Message in case of failure (default: red "failure")
#   -1 <MSG>     Message in case of success (default: green "done")
#   -p  <MSG>    Set prefix for both failure and success
#   -pf <MSG>    Prefix for failed operation message
#   -ps <MSG>    Prefix for successful operation message
#   -s  <MSG>    Set suffix for both failure and success
#   -sf <MSG>    Suffix for failed operation message
#   -ss <MSG>    Suffix for successful operation message
# Params:
#   $1    <psexit> Process status exit (0 is success, > 0 is failure)
#  [$*]   <echo-args> Arguments for echo (except -e)
# Dependencies:
#   echo
#------------------------------------------------------------------------------
print_result() {
  local prefix_failure prefix_success suffix_failure suffix_success
  local msg msg_failure msg_success
  # Parse options
  while : ; do
    case "$1" in
       -0) msg_success="${2}"; shift;;
       -1) msg_failure="${2}"; shift;;
       -p) prefix_failure="$2"; prefix_success="$2"; shift;;
      -pf) prefix_failure="$2"; shift;;
      -ps) prefix_success="$2"; shift;;
       -s) suffix_success="$2"; suffix_failure="$2"; shift;;
      -sf) suffix_failure="$2"; shift;;
      -ss) suffix_success="$2"; shift;;
       -*) : ;; # Do nothing
        *) break;;
    esac
    shift
  done
  # Set defaults if need be
  [[ -z "$msg_failure" ]] && msg_failure="failure"
  [[ -z "$msg_success" ]] && msg_success="done"
  if [[ "$1" -eq 0 ]]; then
    msg="${prefix_success}${msg_success}${suffix_success}"
  else
    msg="${prefix_failure}${msg_failure}${suffix_failure}"
  fi
  echo "${@:2}" -e "$msg"
}
