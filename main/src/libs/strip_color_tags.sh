#! /bin/bash

#------------------------------------------------------------------------------
# Strips all color tags from a text.
# Params:
#   $*    Text to strip
# Returns:
#   The text without any color tags.
#------------------------------------------------------------------------------
strip_color_tags() {
  echo -e "$@" | sed -r "s:\x1B\[[0-9;]*[mK]::g"
}
