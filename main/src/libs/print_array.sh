#! /bin/bash

#------------------------------------------------------------------------------
# Transforms an array into a proper string representation.
# Params:
#   $*    Elements of the array
# Returns:
#   The string representation of the array
#------------------------------------------------------------------------------
print_array() {
  # Print each element
  local arg
  for arg; do
    echo -n "$arg"
    # Print a comma while it's not the last element
    [[ $# -gt 1 ]] && echo -n ", "
    shift
  done
  echo ""
}
