#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Returns the first longest value amongst all provided entries.
# Params:
#   $*    <haystack..> Entries to compare
# Options:
#   -i    Will return the index of the longest (-1 if no value)
#   -s    Will return the size of the longest (0 if no value)
# Returns:
#   The longest value (according to options) or nothing if there's no value
# Dependencies:
#   echo
#------------------------------------------------------------------------------
longest() {
  local size=0 index=-1 current=0
  local _return_type=LONGEST _result=''
  # Arg parsing
  while : ; do
    case "$1" in
      -i) _return_type=INDEX;;
      -s) _return_type=SIZE;;
       *) break;;
    esac
    shift
  done
  # Check
  for var; do
    [[ "${#var}" -gt $size ]] && { size=${#var}; index=$current; }
    ((current++))
  done
  # Specify return
  case "$_return_type" in
    # Increase index by 1 since $0 is the method name
    LONGEST) [[ $index -ge 0 ]] && { ((index++)); _result="${!index}"; } ;;
    INDEX) _result=$index ;;
    SIZE) _result="$size" ;;
  esac
  echo "$_result"
}
