#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Checks if a function is defined.
# Params:
#   $1    <fnc> Name of the function
# Returns:
#   0/true if the function exists, 1/false otherwise
#------------------------------------------------------------------------------
check_function_exists() {
  local typecheck
  typecheck="$(type -t "$1" 2> /dev/null)"
  #shellcheck disable=SC2181
  [[ $? -eq 0 ]] && [[ "$typecheck" == "function" ]]
}
