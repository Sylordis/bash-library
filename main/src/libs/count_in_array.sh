#! /bin/bash

#------------------------------------------------------------------------------
# Counts how many times an element occurs in an array.
# Params:
#   $1    Needle - the value to search for
#   $*    Haystack - all the values to search in
#           Don't forget to surround this argument by quotes to prevent bash
#           expansion of values (especially with star character)
# Returns:
#   The number of occurences of one token in the array, 0 if the array is empty
#------------------------------------------------------------------------------
count_in_array() {
  local v count=0
  # Loop through the haystack
  for v in "${@:2}"; do
    [[ "$v" == "$1" ]] && ((count++))
  done
  # Return counter
  echo "$count"
}
