#! /bin/bash

#==============================================================================
# This file can be sourced or included as is in a bash script.
# It contains a lot of utilities for output formatting, including colors, columns,
# result printing.
# You can declare the following variables:
# - for color():
#   - COLOR_ERROR
#   - COLOR_SUCCESS
#   - COLOR_UNKNOWN
# - for print_column():
#   - COLUMNS_PADDING: sets the padding between columns (default=3)
#   - COLUMN_SIZE: sets the column size (default=30)
# - for t():
#   - TAB_LENGTH: in spaces to simulate tabs in t() (default=5)
#==============================================================================

#------------------------------------------------------------------------------
# Colors the message in a given color.
# Parameters:
#   $1    Color codes to be applied
#   $*    Message to be colored
#------------------------------------------------------------------------------
color() {
  echo -e "\e[${1}m${*:2}\e[0m"
}
# Short aliases for specific colors
cbold() { color '1' "$@"; }
cdim() { color '2' "$@"; }
cerror() { color "${COLOR_ERROR-31}" "$@"; }
csuccess() { color "${COLOR_SUCCESS-32}" "$@"; }
cunknown() { color "${COLOR_UNKNOWN-93}" "$@"; }
# Colors
cblack() { color '30' "$@"; }
ccyan() { color '36' "$@"; }
cgray() { color '90' "$@"; }
cgreen() { color '32' "$@"; }
cmagenta() { color '35' "$@"; }
cred() { color '31' "$@"; }
cyellow() { color '33' "$@"; }
cwhite() { color '97' "$@"; }
# Light colors
clblue() { color '94' "$@"; }
clcyan() { color '96' "$@"; }
clgray() { color '37' "$@"; }
clgreen() { color '92' "$@"; }
clmagenta() { color '95' "$@"; }
clred() { color '91' "$@"; }
clyellow() { color '93' "$@"; }

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
# Short aliases
t() { margin $((${TAB_LENGTH-5} * ${1-1})); }

#------------------------------------------------------------------------------
# Normalises the printing of columns according to COLUMN_SIZE variable.
# This method will print some text without a new line.
# Parameters:
#   $*    Message to be printed
# Options:
#   -r        Aligns column to the right
#   -s <size> Fixes the size of the column
#------------------------------------------------------------------------------
print_column() {
  local o_align='-' c_opts c_size=${COLUMN_SIZE-30}
  while : ; do
    case "$1" in
      -r) o_align='';;
      -s) c_size="$2"; shift;;
       *) break;;
    esac
    shift
  done
  c_opts="$o_align$c_size"
  printf "%${c_opts}s%s" "$*" "$(margin "${COLUMNS_PADDING-3}")"
}
