#! /usr/bin/env bash

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
# - for tab():
#   - TAB_LENGTH: in spaces to simulate tabs in tab() (default=5)
# - for wrap():
#   - WRAP_SIZE: sets the length for wrapping (default=terminal length).
#==============================================================================

#------------------------------------------------------------------------------
# Colours the message in a given color.
# Parameters:
#   $1    Colour codes to be applied
#   $*    Message to be colored
# Returns:
#   Colour encoded provided string, or just the string if an error happens.
#------------------------------------------------------------------------------
color() {
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    echo -e "\e[${1}m${*:2}\e[0m"
  else
     echo "$2"
   fi
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
#   $1    Number of white spaces to put (default 1)
#  [$2]   Pattern/character to put in margin instead of whitespaces
# Returns:
#   The margin character, repeated as many times as desired.
#------------------------------------------------------------------------------
margin() {
  [[ "$1" =~ ^[0-9]+$ ]] || return 1
  local _num="$1"
  local _mtxt="$2"
  printf "${_mtxt:= }%.0s" $(seq 1 1 "${_num:=1}")
}
# Short aliases
m() { margin "$@"; }

#------------------------------------------------------------------------------
# Creates a tabulation of N spaces. N is based on definition of TAB_LENGTH
# variable, with a default of 5.
# Params:
#   [$1]  Number of tabulations (default 1)
# Returns:
#   N times TAB_LENGTH value as spaces, nothing if an error occurs.
#------------------------------------------------------------------------------
tab() {
  [[ "$1" =~ ^[0-9]*$ ]] || return 1
  margin $((${TAB_LENGTH-5} * ${1-1}));
}
# Short aliases
t() { tab "$@"; }

#------------------------------------------------------------------------------
# Normalises the printing of columns according to COLUMN_SIZE variable.
# This method will print some text without a new line.
# Params:
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
      -s) [[ "$2" =~ ^[0-9]+$ ]] || return 1; c_size="$2"; shift;;
       *) break;;
    esac
    shift
  done
  c_opts="$o_align$c_size"
  printf "%${c_opts}s%s" "$*" "$(margin "${COLUMNS_PADDING-3}")"
}

#------------------------------------------------------------------------------
# Spans a message in a given message length, aligning to the left.
# Does not output a zero character at the end.
# Params:
#   $1    Final length of the message (integer)
#   $*    Strings to align
#------------------------------------------------------------------------------
align_left() {
  [[ "$1" =~ ^[0-9]+$ ]] || return 1
  printf "%-*s" "$1" "${*:2}"
}
# Short alias
a_left() { align_left "$@"; }
a_l() { align_left "$@"; }

#------------------------------------------------------------------------------
# Spans a text in a given message length, aligning at the center. If the
# text is too long for the size, just outputs the text.
# Does not output a zero character at the end.
# Params:
#   $1    Final length of the message
#   $*    Strings to align
#------------------------------------------------------------------------------
align_center() {
  [[ "$1" =~ ^[0-9]+$ ]] || return 1
  local size="$1"
  local msg="${*:2}"
  local msg_size="${#msg}"
  local pad_left pad_right
  # Return normal message if too long
  [[ "$size" -le "$msg_size" ]] && { echo "$msg"; return 0; }
  pad_right=$(((size - msg_size)/2))
  pad_left=$((size - msg_size - pad_right))
  printf '%*s%s%*s' "$pad_left" '' "$msg" "$pad_right" ''
}
# Short alias
a_center() { align_center "$@"; }
a_ctr() { align_center "$@"; }

#------------------------------------------------------------------------------
# Spans a message in a given message length, aligning to the right.
# Does not output a zero character at the end.
# Params:
#   $1    Final length of the message
#   $*    Strings to align
#------------------------------------------------------------------------------
align_right() {
  [[ "$1" =~ ^[0-9]+$ ]] || return 1
  printf "%*s" "$1" "${*:2}"
}
# Short alias
a_right() { align_right "$@"; }
a_r() { align_right "$@"; }
