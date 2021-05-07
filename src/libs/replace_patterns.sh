#! /bin/bash

#------------------------------------------------------------------------------
# Takes a string a replaces all patterns, which are enclosed by '__'. The pattern
# values will be taken from variables of the same name as the pattern itself, so
# '__VALUE__' would take its value from the bash variable '$VALUE'.
# Only characters allowed in patterns are uppercases characters and single
# underscores.
# Params:
#   $1    Text to replace patterns in.
# Options:
#   -p <V>  Sets a prefix for pattern values variable correspondance. Default is
#           empty.
# Returns:
#   The text with all patterns replaced by their values.
#------------------------------------------------------------------------------
replace_patterns() {
  local o_delim_b o_delim_e o_prefix
  o_delim_b='__'
  o_delim_e="$o_delim_b"
  o_prefix=''
  # Option parsing
  while : ; do
    case "$1" in
      -p) o_prefix="$2"; shift;;
       *) break;;
    esac
    shift
  done
  # Real processing begins
  local txt patt value patt_var
  txt="$1"
  # Get all patterns
  patterns=($(grep -o -Ee "$o_delim_b([A-Z]+_)*[A-Z]+$o_delim_e" <<< "$1" | sort -u))
  for patt in "${patterns[@]}"; do
    # Get variable name corresponding to the pattern
    patt_var="$(sed -re "s&^$o_delim_b(.*)$o_delim_e\$&\1&g" <<< "$patt")"
    # Get the value for the pattern
    local -n value="${o_prefix}${patt_var}"
    # Replace
    txt="${txt//$patt/$value}"
  done
  unset patterns
  # Return processed string
  echo "$txt"
}
