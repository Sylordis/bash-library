#! /bin/bash

#------------------------------------------------------------------------------
# Returns the first longest amongst all provided entries.
# Params:
#   $*    Entries to compare
# Options:
#   -i    Will return the index of the longest (-1 if no value)
#   -s    Will return the size of the longest (0 if no value)
# Returns:
#   The longest value (according to options) or nothing if there's no value
#------------------------------------------------------------------------------
longest() {
  local size=0 index=-1 current=0
  local _return_type=0 _result=''
  # Arg parsing
  while : ; do
    case "$1" in
      -i) _return_type=1;;
      -s) _return_type=2;;
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
    0) ((index++)); [[ $index -ne 0 ]] && _result="${@:$index:1}" ;;
    1) _result=$index ;;
    2) _result="$size" ;;
  esac
  echo "$_result"
}
