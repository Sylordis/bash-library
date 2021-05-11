#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Strips all colour tags from a string.
# Params:
#   $*    <string> String to strip colours from
# Returns:
#   The text without any color tags.
#------------------------------------------------------------------------------
strip_color_tags() {
  echo -e "$@" | sed -r "s:\x1B\[[0-9;]*[mK]::g"
}
