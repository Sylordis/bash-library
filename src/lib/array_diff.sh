#! /usr/bin/env bash

# Includes
source "$SH_PATH_LIB/in_array.sh"

#------------------------------------------------------------------------------
# Forms a new array resulting of the subtraction of the second array from the
# first one (R = A1 - A2). Preserves the order of elements in the first array.
# Params:
#   $1    <array1> First array name
#   $2    <array2> Second array name
#   $3    <result_array> Resulting array name
# Returns:
#   Nothing but creates a new variable containing an array with the difference.
#------------------------------------------------------------------------------
array_diff() {
  # Create empty result array
  local -n _array1="$1"
  local -n _array2="$2"
  local -n _array3="$3"
  # Empty the result variable just in case
  _array3=()
  # Loop on each element of first array
  local v
  for v in "${_array1[@]}"; do
    # Add value if not in second array
    ! in_array "$v" "${_array2[@]}" && _array3+=("$v")
  done
}
