#! /bin/bash

#------------------------------------------------------------------------------
# Checks if two arrays are the same.
# Params:
#   $1  First array name
#   $2  Second array name
# Returns:
#   0/true if both variables are arrays that contains the same values in the
#   same order, 1/false otherwise.
#------------------------------------------------------------------------------
array_equals() {
  local flag
  if [[ $# -eq 0 ]]; then
    flag=0
  elif [[ $# -eq 1 ]]; then
    flag=1
  else
    # Check that both variables are arrays
    local _type1 _type2
    _type1="$(declare -p "$1" 2> /dev/null | cut -d ' ' -f 2)"
    _type2="$(declare -p "$2" 2> /dev/null | cut -d ' ' -f 2)"
    if [[ "$_type1" == "-a" && "$_type2" == "-a" ]]; then
      # Get data
      local -n _array1="$1"
      local -n _array2="$2"
      local diff
      diff=$(diff <(printf "%s\n" "${_array1[@]}") <(printf "%s\n" "${_array2[@]}"))
      [[ -n "$diff" ]] && flag=1
      unset _array1 _array2
    else
      flag=1
    fi
  fi
  return $flag
}
