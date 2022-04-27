#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Gets the index of a value in an array.
# Params:
#   $1    <needle> value to search for
#   $*    <haystack..> values of the array
# Returns:
#   the index of the first occurence of the value in the array, or -1 if it
#   cannot be found.
# Dependencies:
#   echo
#------------------------------------------------------------------------------
find_in_array() {
  local v i=-1 c=0
  for v in "${@:2}"; do
    [[ "$1" == "$v" ]] && { i=$c; break; }
    ((c++))
  done
  echo $i
}
