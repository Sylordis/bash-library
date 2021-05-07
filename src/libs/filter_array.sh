#! /bin/bash

#------------------------------------------------------------------------------
# Filters an array according to given conditions, and creates a new array with
# given name. If the operation fails (wrong input type), no array will be created.
# Params:
#   $1    Array to filter
#   $2    Array resulting after filtering
#   $3    Filter, a bash condition written in text, This filter will be
#         evaluated by bash. Usable patterns:
#             %ARG%   current value being checked for filtering.
#             %ARG_N% index of the current value.
# Returns:
#   0/true if input is an array and the operation succeeded, 1/false otherwise.
#------------------------------------------------------------------------------
filter_array() {
  local op_result=0
  # Less arguments than anticipated, error
  if [[ $# -lt 2 ]]; then
    op_result=1
  else
    # Check if input is array
    local input_type
    input_type="$(declare -p "$1" 2>/dev/null | cut -d ' ' -f 2)"
    # References to actual arrays
    local -n array_in="$1"
    local -n array_out="$2"
    if [[ "$input_type" != "-a" ]]; then
      op_result=1
    elif [[ $# -eq 2 ]] || [[ -z "$3" ]]; then
      array_out=("${array_in[@]}")
    else
      array_out=()
      local arg result
      for arg in "${array_in[@]}"; do
        eval "${3//%ARG%/$arg}"
        result=$?
        if [[ $result -eq 0 ]]; then
          array_out+=("$arg")
        fi
      done
      unset _input_array
    fi
  fi
  return $op_result
}
