#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Forms a new array containing the elements which are not present in both
# given arrays. R = A Δ B = ( A \ B ) ∪ (B \ A ).
# There is no assumption about the order of elements in the resulting array.
# Params:
#   $1    <array1> First array name
#   $2    <array2> Second array name
#   $3    <result_array> Resulting array name
# Returns:
#   Nothing but creates a new variable containing an array with all differences
# Dependencies:
#   comm, printf
#------------------------------------------------------------------------------
array_symmetric_diff() {
  local -n _array1="$1"
  local -n _array2="$2"
  local -n _array_res="$3"
  readarray -t _array_res < <(comm --output-delimiter=$'\t' -3 \
      <([[ ${#_array1[@]} -gt 0 ]] && printf '%s\n' "${_array1[@]}") \
      <([[ ${#_array2[@]} -gt 0 ]] && printf '%s\n' "${_array2[@]}") \
          | tr -d $'\t')
}
