#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Will write messages to the console only, uncatchable by redirections.
# Every argument will be appened to one line with 'echo -e'. If one of the
# arguments given is a variable, the method will print its content, with a format
# dependent on the type of the variable (array or text/number).
# Some variables can be set to modify the output of this script:
#   DEBUG_DISPLAY_PREFIX={0,1}  If set to 0, displays debug prefix for all calls,
#                               unless -np is used, if set to 0.
#                               If set to 1, similar to option -np for all calls.
#                               Default value: 0.
#   DEBUG_PREFIX_TREE={0,1}     If set to 0, applies -t to all calls.
#                               Default value: 1.
#   DEBUG_PREFIX_SRC={0,1}      If set to 0, applies option -src to all calls.
#                               Default value: 1.
#   DEBUG_MODE={0,1}            If set to 1, this method will not output anything.
#                               Default value: 0.
# Params:
#   $*    <args..>  Messages to log / variable names to dump
# Options:
#   -t    Displays function tree call
#   -np   Prevents prefix display
#   -src  Displays the source in the prefix
#------------------------------------------------------------------------------
debug() {
  local _msg _data _o_prefix _o_src _o_mode _o_tree
  _msg=""
  _o_prefix="${DEBUG_DISPLAY_PREFIX:-0}"
  _o_src="${DEBUG_PREFIX_SRC:-1}"
  _o_tree="${DEBUG_PREFIX_TREE:-1}"
  _o_mode="${DEBUG_MODE:-0}"
  # Option parsing
  while : ; do
    case "$1" in
      -np) _o_prefix=1;;
     -src) _o_src=0;;
       -t) _o_tree=0;;
        *) break;;
    esac
    shift
  done
  [[ $_o_mode -eq 1 ]] && return 0
  # Prefix, check if it has to be displayed
  if [[ $_o_prefix -eq 0 ]] \
      && { [[ $_o_src -eq 0 ]] || \
      { [[ $_o_src -eq 1 ]] && [[ ${#FUNCNAME[@]} -gt 2 ]]; }; }; then
    _msg+="\e[94m["
    # Add source name
    [[ $_o_src -eq 0 ]] && _msg="$_msg$(basename "$0")"
    # Check if there's a function to append to source name
    [[ $_o_src -eq 0 ]] && [[ ${#FUNCNAME[@]} -gt 2 ]] && _msg="$_msg#"
    # Add function name(s) if there's any
    if [[ ${#FUNCNAME[@]} -gt 2 ]]; then
      # Display ancestor's tree if there's any
      if [[ $_o_tree -eq 0 ]]; then
        for (( idx=${#FUNCNAME[@]}-2; idx > 1; idx-- )); do
          _msg+="${FUNCNAME[idx]}()::"
        done
      fi
      # Add last method call at the end
      _msg+="${FUNCNAME[1]}()"
    fi
    _msg+="]\e[39m"
  fi
  # Real message
  while [[ $# -ne 0 ]] ; do
    [[ -n "$_msg" ]] && _msg+=' '
    if [[ "$1" == -* ]]; then
      # Prevent declare options
      _data=""
    else
      # Check if variable
      _data="$(declare -p "$1" 2> /dev/null)"
    fi
    # Check if there is any data to use (= variable)
    if [[ -n "$_data" ]]; then
      local _var_type
      _var_type="$(cut -d ' ' -f 2 <<< "$_data")"
      case "$_var_type" in
        -a) # Normal arrays, reprint array and add cardinality
            local -n _array="$1"
            _msg+="$1=($(printf '"%s" ' "${_array[@]}")\b)|${#_array[@]}|";;
        -A) # Associative arrays, reformat a bit and add cardinality
            local -n _array="$1"
            # Empty associate arrays do not have values
            if [[ ${#_array[@]} -eq 0 ]]; then
              _msg+="$1=()|0|"
            else
              _msg+="$(cut -d ' ' -f 3- <<< "$_data")\b\b)|${#_array[@]}|"
            fi;;
         *) # Normal case, just take the dump from declare
            _msg+="$(cut -d ' ' -f 3- <<< "$_data")";;
      esac
    else
      _msg+="$1"
    fi
    shift
  done
  echo -e "% \e[2m$_msg\e[0m" > /dev/tty
}
