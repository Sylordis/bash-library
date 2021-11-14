#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Loops on all immediate directories of the current directory and run commands
# given as arguments.
# Args:
#   $*    Command to run for each directory
#         Use __DIR__ as a placeholder for the name of the folder
# Options:
#   -e      Command is only one argument to eval
#   -f      Provides a list of all directories for which the command failed
#   -l args Arguments for find
#   -s X    Sleep X seconds between each operation
#------------------------------------------------------------------------------
foreach() {
  local dir short sleep_dur=0 find_cmd eval_cmd=1 failure_list=1
  local find_args='-maxdepth 1 -type d -not -name . -not -name .. -prune'
  _failures=()
  # Options check
  while : ; do
    case "$1" in
      -e) eval_cmd=0;;
      -f) failure_list=0;;
      -l) find_args="$2"; shift;;
      -s) sleep_dur="$2"; shift;;
      *) break;;
    esac
    shift
  done
  # Foreach directory
  while read dir; do
    short="${dir#'./'}"
    echo -e "\e[94m$dir\e[0m:"
    (
      cd "$dir"
      if [[ $eval_cmd -eq 0 ]]; then
        eval "${*//__DIR__/$short}"
      else
        "${@//__DIR__/$short}"
      fi
    )
    local ps_res=$?
    if [[ $ps_res -ne 0 ]] && [[ $failure_list -eq 0 ]]; then
      _failures+=( "$dir" )
    fi
    # Make it sleep if requested
    if [[ $sleep_dur -gt 0 ]]; then
      sleep $sleep_dur
    fi
  done < <(find . $find_args)
  if [[ ${#_failures[@]} -gt 0 ]]; then
    echo -e "\n\e[31mFailures[${#_failures[@]}]:\e[0m " "${_failures[@]}"
  fi
  unset _failures
}
# Alias to iterate on all git repositories located under current directory
forgit() {
  foreach -l "-name .git -prune -exec dirname {} ;" "$@"
}
