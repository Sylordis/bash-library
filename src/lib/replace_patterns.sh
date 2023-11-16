#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Takes a string a replaces all patterns, which are enclosed by '__'. The pattern
# values will be taken from variables of the same name as the pattern itself, so
# '__VALUE__' would take its value from the bash variable '$VALUE'.
# Only characters allowed in patterns are uppercases characters and single
# underscores.
# Params:
#   $1    <string> Text to replace patterns in
# Options:
#   -d <delim>
#           Sets the pattern delimiters (both begin and end).
#           Overrides -db and -de.
#   -D|--default <default>
#           Sets a default value for variables that cannot be linked to a variable.
#           Incompatible with --lenient.
#   -db <delim>
#           Sets the pattern start delimiter.
#   -de <delim>
#           Sets the pattern end delimiter.
#   -L|--lenient
#           The method wil not replace patterns that cannot be linked to a variable.
#           Incompatible with --default.
#   -p <prefix>
#           Sets a prefix for pattern values variable correspondance. Default is
#           empty.
# Returns:
#   The text with all patterns replaced by their values.
# Dependencies:
#   echo, grep, sed, sort
#------------------------------------------------------------------------------
replace_patterns() {
  local o_delim_b o_delim_e o_prefix o_lenient o_default
  o_delim_b='__'
  o_delim_e="$o_delim_b"
  o_prefix=''
  o_lenient=1
  o_default=''
  # Option parsing
  while : ; do
    case "$1" in
      -d) o_delim_b="$2"; o_delim_e="$2"; shift;;
      -D|--default) o_default="$2"; shift;;
     -db) o_delim_b="$2"; shift;;
     -de) o_delim_e="$2"; shift;;
     -L|--lenient) o_lenient=0;;
      -p) o_prefix="$2"; shift;;
       *) break;;
    esac
    shift
  done
  # Real processing begins
  local txt patt value patt_var var_name
  txt="$1"
  # Get all patterns
  patterns=()
  readarray -t patterns < <(grep -o -Ee "$o_delim_b([A-Z0-9]+_)*[A-Z0-9]+$o_delim_e" <<< "$1" | sort -u)
  for patt in "${patterns[@]}"; do
    # Get variable name corresponding to the pattern
    patt_var="$(sed -re "s&^$o_delim_b(.*)$o_delim_e\$&\1&g" <<< "$patt")"
    # Get the value for the pattern
    local -n value="${o_prefix}${patt_var}"
    # Check if linked variable has a value
    var_name="$o_prefix$patt_var"
    if [[ -z "${!var_name+x}" ]]; then
      if [[ $o_lenient -eq 0 ]]; then
        value="$o_delim_b${var_name}$o_delim_e"
      else
        value="$o_default"
      fi
    fi
    # Replace
    txt="${txt//"$patt"/"$value"}"
  done
  unset patterns
  # Return processed string
  echo "$txt"
}
