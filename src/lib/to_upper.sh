#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Changes all characters in a string to uppercase.
# Apply any color tags after applying this method.
# Params:
#   $*    <strings..> Any string
# Returns:
#   The uppercased string.
# Dependencies:
#   tr
#------------------------------------------------------------------------------
to_upper() {
  tr '[:lower:]' '[:upper:]' <<< "$@"
}
