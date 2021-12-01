#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Loops on all immediate directories of the current directory and run commands
# given as arguments.
# Args:
#   $*    Command to run for each directory
#         Use __DIR__ as a placeholder for the name of the folder
# Options:
#   -c      Adds colours to output
#   -e      Command is only one argument to eval
#   -f      Provides a list of all directories for which the command failed
#   -l args Arguments for find
#   -q      Quiet mode. Do not print the folder names
#   -s N    Sleep N seconds between each operation
#------------------------------------------------------------------------------
foreach() {
  _c_dir() { echo "$@"; }
  _c_fail() { echo "$@"; }
  local dir short _opt
  local _opt_sleep=0 _opt_eval=1 _opt_failed=1 _opt_quiet=1 _opt_colour=1
  local find_args='-maxdepth 1 -type d -not -name . -not -name .. -prune'
  _failures=()
  # Options check
  while getopts ':cefl:qs:' _opt; do
    case "$_opt" in
      c) _opt_colour=0;;
      e) _opt_eval=0;;
      f) _opt_failed=0;;
      l) find_args="${OPTARG}";;
      q) _opt_quiet=0;;
      s) _opt_sleep="${OPTARG}"
         if ! [[ "$_opt_sleep" =~ ^(0\.)?[0-9]+$ ]]; then
           echo "ERROR[$FUNCNAME]: option -s expects positive integer argument (was '$_opt_sleep')." >& 2
           return 1
         fi;;
      :) echo "ERROR[$FUNCNAME]: option -${OPTARG} expects an argument." >& 2
          return 1;;
      # Do not trigger error on unknown option
      *) : ;;
    esac
  done
  shift $((OPTIND-1))
  # Redefine output methods
  if [[ $_opt_colour -eq 0 ]]; then
    _c_dir() { echo "\e[94m$*\e[0m"; }
    _c_fail() { echo "\e[31m$*\e[0m"; }
  fi
  # Foreach directory
  while read -r dir; do
    short="${dir#'./'}"
    [[ $_opt_quiet -eq 1 ]] && echo -e "$(_c_dir "${dir}"):"
    # Pop a subshell so interrupting the script won't change the current directory
    (
      cd "$dir" || return 1
      if [[ $_opt_eval -eq 0 ]]; then
        eval "${*//__DIR__/$short}"
      else
        "${@//__DIR__/$short}"
      fi
    )
    local ps_res=$?
    if [[ $ps_res -ne 0 ]] && [[ $_opt_failed -eq 0 ]]; then
      _failures+=( "$dir" )
    fi
    # Make it sleep if requested
    [[ $_opt_sleep -gt 0 ]] && sleep "$_opt_sleep"
  done < <(find . $find_args)
  # Print failures if list was constructed
  if [[ ${#_failures[@]} -gt 0 ]]; then
    [[ $_opt_quiet -eq 1 ]] && echo
    echo -e "$(_c_fail "Failures[${#_failures[@]}]:")" "${_failures[@]}"
  fi
  unset _failures _c_dir _c_fail
}
# Alias to iterate on all git repositories located under current directory
forgit() {
  foreach -l "-name .git -prune -exec dirname {} ;" "$@"
}
