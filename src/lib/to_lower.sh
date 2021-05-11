#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Changes all characters in a string to lowercase.
# Apply any color tags after applying this method.
# Params:
#   $*    <strings..> Any string
# Returns:
#   The lowercased string.
#------------------------------------------------------------------------------
to_lower() {
  tr '[:upper:]' '[:lower:]' <<< "$@"
}
