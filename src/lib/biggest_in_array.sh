#! /usr/bin/env bash

# Includes
source "$SH_PATH_LIB/is_number.sh"

#------------------------------------------------------------------------------
# Returns the biggest element in a set of values. By default only takes
# numbers, but options can change that.
# Params:
#   $*    <haystack..> All values to search in
# Options:
#   -tl   Also considers the length of strings in the array. Default with -tlo option.
#   -tlo  Considers the length of texts only.
# Returns:
#   Empty string/status 1 if there's no element, the biggest/status 0 otherwise
#------------------------------------------------------------------------------
biggest_in_array() {
  local text_length=1;
  local text_length_only=1;
  while :
  do
    case "$1" in
     -tl) text_length=0;;
    -tlo) text_length_only=0; text_length=0;;
       *) break;;
    esac
    shift
  done
  # No arguments, exit
  if [[ $# -eq 0 ]]; then
    echo "0"
    return 1
  fi
  local biggest=""
  local comparator=-999999
  # Loop through the haystack
  local v
  for v in "$@"; do
    local current=$comparator;
    if is_number "$v" && [[ $text_length_only -eq 1 ]]; then
      current="$v"
    elif ! is_number "$v" && [[ $text_length -eq 0 ]]; then
      current="${#v}"
    fi
    # Check max
    if [[ $current -gt $comparator ]]; then
      comparator=$current
      biggest=$v
    fi
  done
  # Return counter
  echo "$biggest"
  return 0
}
