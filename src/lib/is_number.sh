#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Checks if the given argument is a number or not. Accepts floating and negative
# numbers.
# Params:
#   $1    <value> The value to check
# Returns:
#   0/true if the value is a number, 1/false otherwise
# Dependencies:
#   grep
#------------------------------------------------------------------------------
is_number() {
  grep -qE '^[-]?[0-9]+([,.][0-9]+)?$' <<< "$1"
}
