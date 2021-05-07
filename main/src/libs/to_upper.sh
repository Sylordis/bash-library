#! /bin/bash

#------------------------------------------------------------------------------
# Changes all characters in a string to uppercase.
# Apply any color tags after applying this method.
# Params:
#   $*    Any string
# Returns:
#   The uppercased string.
#------------------------------------------------------------------------------
to_upper() {
  tr '[:lower:]' '[:upper:]' <<< "$@"
}
