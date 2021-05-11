#! /usr/bin/env bash


#------------------------------------------------------------------------------
# Applies multiple transformations to a text, given the name of the required
# methods to apply. The methods have to accept the text as first argument.
# Params:
#   $1    <string> Text to transform
#   $*    <fncs..> Methods to apply for transformation
# Returns:
#   The transformed text
#------------------------------------------------------------------------------
apply_transformations() {
  local _txt="$1"
  shift
  local _fnc _typecheck
  for _fnc; do
    # Check if function exists
    _typecheck="$(type -t "$_fnc")"
    [[ "$_typecheck" == "function" ]] && _txt="$($_fnc "$_txt")"
  done
  echo "$_txt"
}
