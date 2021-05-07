#! /bin/bash

#------------------------------------------------------------------------------
# Prints a number of character on stdout. If no character is given as second
# argument, simply prints white spaces. This method does NOT print a new line
# at the end of its output.
# Params:
#   $1    Number of white spaces to put
#  [$2]   Pattern/character to put in margin instead of whitespaces
# Returns:
#   The margin character, repeated as many times as desired.
#------------------------------------------------------------------------------
margin() {
  local _num="$1"
  local _mtxt="$2"
  printf "${_mtxt:= }%.0s" $(seq 1 1 "${_num:=1}")
}
