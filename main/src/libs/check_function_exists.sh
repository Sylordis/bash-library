#! /bin/bash

#------------------------------------------------------------------------------
# Checks if a function is defined.
# Params:
#   $1    Name of the function
# Returns:
#   0/true if the function exists, 1/false otherwise
#------------------------------------------------------------------------------
check_function_exists() {
  local typecheck
  typecheck="$(type -t "$1" 2> /dev/null)"
  [[ $? -eq 0 ]] && [[ "$typecheck" == "function" ]]
}
