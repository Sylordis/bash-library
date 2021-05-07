#! /bin/bash

#------------------------------------------------------------------------------
# Changes all characters in a string to lowercase.
# Apply any color tags after applying this method.
# Params:
#   $*    Any string
# Returns:
#   The lowercased string.
#------------------------------------------------------------------------------
to_lower() {
  tr '[:upper:]' '[:lower:]' <<< "$@"
}
