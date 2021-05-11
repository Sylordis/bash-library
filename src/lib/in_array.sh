#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Checks if a value is contained in an array.
# Params:
#   $1    <needle> the value to search for
#   $*    <haystack..> all the values to search in
#         Don't forget to surround this argument by quotes to prevent bash
#         expansion of values (especially while using star-character.)
# Returns:
#   0/true if the value is in the array, 1/false otherwise
#------------------------------------------------------------------------------
in_array() {
  local v
    # Loop through the haystack
  for v in "${@:2}"; do
    # Value found, return true
    [[ "$v" == "$1" ]] && return 0
  done
  # Value not found, return false
  return 1
}
