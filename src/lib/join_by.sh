#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Joins all the elements given as argument with one expression.
# Params:
#   $1    <join-str> Joining string
#   $*    <strs..> Strings to join together
# Returns:
#   All the elements joined.
#------------------------------------------------------------------------------
join_by() {
  local d="$1"
  shift
  echo -n "$1"
  shift
  printf "%s" "${@/#/$d}"
  echo
}
