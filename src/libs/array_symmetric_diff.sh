#! /bin/bash

#------------------------------------------------------------------------------
# array_symmetric_diff()
# Forms a new array containing the elements which are not present in both
# given arrays. There is no assumption about the sorting of the resulting
# array.
# Params:
#   $1    First array name
#   $2    Second array name
#   $3    Resulting array name
# Returns:
#   Nothing but creates a new variable containing an array with all differences
#------------------------------------------------------------------------------
array_symmetric_diff() {
  local -n _array1="$1"
  local -n _array2="$2"
  local -n _array_res="$3"
  IFS=$'\n\t' _array_res=($(comm -3 <(printf '%s\n' "${_array1[@]}") <(printf '%s\n' "${_array2[@]}")))
}
