#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Trim whitespaces and tabs both leading and trailing an expression.
# Params:
#   $*    <string> Expressions to trim
# Options:
#   -l    Trim leading characters only
#   -t    Trim trailing characters only
#   -f    Only trim first occurrence of replacement (whitespace or set string)
#         for leading and/or trailing
#   -r S  Trim string S instead of whitespaces. Also removes the repetitions
#         of S. Follows sed regexp syntax.
# Dependencies:
#   echo, printf
#------------------------------------------------------------------------------
trim() {
  local _char _cmd _expr _final
  local o_leading o_trailing o_first
  _char="[[:space:]]|$(printf '\t')"
  _final=""
  o_leading=0
  o_trailing=0
  o_first=1
  # Option parsing
  while : ; do
    case "$1" in
      -f) o_first=0;;
      -l) o_trailing=1;;
      -t) o_leading=1;;
      -r) _char="$2"; shift;;
       *) break;;
    esac
    shift
  done
  _cmd="sed -r"
  _expr="($_char)"
  [[ $o_first -ne 0 ]] && _expr="$_expr+"
  [[ $o_leading -eq 1 && $o_trailing -eq 1 ]] && { echo "$@" ; return 1; }
  [[ $o_leading -eq 0 ]] && _cmd="$_cmd -e 's/^$_expr//g'"
  [[ $o_trailing -eq 0 ]] && _cmd="$_cmd -e 's/$_expr$//g'"
  for arg; do
    [[ -n "$_final" ]] && _final="$_final "
    _final="$_final$(eval "echo '$arg' | $_cmd")"
  done
  echo "$_final"
}
