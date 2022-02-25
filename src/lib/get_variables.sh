#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Returns all variables which names matches the given pattern.
# Params:
#   $1    <pattern> Pattern for variable names
# Returns:
#   A list of variables if they exist
# Dependencies:
#   grep
#------------------------------------------------------------------------------
get_variables() {
  compgen -A variable | grep -E "^${1}$"
}
