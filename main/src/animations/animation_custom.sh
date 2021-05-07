#! /bin/bash

#------------------------------------------------------------------------------
# animation_custom()
# Displays different symbols after each other in a loop, allowing the user to
# create the animation they want.
# Params:
#   $*    Symbols for the animation
# Options:
#   -d <D>      Delay between each animation (default=0.25)
#   -m <msg>    Specifies a message as template for the whole animation
#                Use pattern %ANIM% for the emplacement of the animation.
#   -pid <PID>  PID of the program to wait for
#   -n          Display a new line when the animation ends
#------------------------------------------------------------------------------
animation_custom() {
  local opt_pid opt_delay opt_newline=1 count max=0 message='%ANIM%'
  opt_delay=0.25
  # Options check
  while : ; do
    case "$1" in
        -d) opt_delay="$2"; shift;;
        -m) message="$2"; shift;;
        -n) opt_newline=0;;
      -pid) opt_pid="$2"; shift;;
         *) break;;
    esac
    shift
  done
  # Arg check
  if [[ $# -lt 1 ]]; then
    echo "ERROR[$FUNCNAME]: No animation symbols given." >& 2
    return 1
  else
    # Get longer animation
    for arg; do
      [[ ${#arg} -gt $max ]] && max=${#arg}
    done
  fi
  count=0
  # Repeat forever if no PID set or until the pid can't be found in the ps list
  while [[ -z "$opt_pid" ]] || grep -q "$opt_pid" <<< "$(ps -ef | awk '{print $2}')"; do
    ((count++))
    echo -en "${message//%ANIM%/$(printf "%-${max}s" "${!count}")}\r"
    [[ $count -eq $# ]] && count=0
    sleep $opt_delay
  done
  [[ $opt_newline -eq 0 ]] && echo
}
