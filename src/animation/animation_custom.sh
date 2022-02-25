#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Displays different symbols after each other in a loop, allowing the user to
# create the animation they want.
# Params:
#   $*    <symbols> Symbols for the animation, one argument per frame.
# Options:
#   -c          Centers the symbol during animation.
#               Equivalent to -m "%-ANIM-%". Overrides -r and -m.
#   -d <D>      Delay between each animation (default=0.25)
#   -m <msg>    Specifies a message as template for the whole animation
#               Use pattern %ANIM% for the emplacement of the animation.
#               Use %-ANIM% for right alignement and %-ANIM-% for centering.
#               This option overrides -c and -r.
#   -n          Display a new line when the animation ends
#   -pid <PID>  PID of the program to wait for
#   -r          Right aligns the symbol during the animation
#               Equivalent to -m "%-ANIM%". Overrides -c and -m.
# Dependencies:
#   awk, echo, grep, printf, sed, sleep
#------------------------------------------------------------------------------
animation_custom() {
  local opt_pid opt_delay opt_newline=1 count max=0 message='%ANIM%' txt
  local align=0 # 0=left, 1=center, 2=right
  opt_delay=0.25
  # Options check
  while : ; do
    case "$1" in
        -c) message='%-ANIM%';;
        -d) opt_delay="$2"; shift;;
        -m) message="$2"; shift;;
        -n) opt_newline=0;;
        -r) message='%-ANIM-%';;
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
  # Check for animation pattern
  if ! grep -qoE '%-?ANIM-?%' <<< "$message"; then
    echo "ERROR[$FUNCNAME]: No animation pattern ('%ANIM%') specified." >& 2
    return 1
  fi
  # Check alignment
  grep -qoF '%-ANIM%' <<< "$message" && align=2
  grep -qoF '%-ANIM-%' <<< "$message" && align=1
  txt="$(sed -E -e 's/(%-?ANIM-?%)/%ANIM%/g' <<< "$message")"
  # Repeat forever if no PID set or until the pid can't be found in the ps list
  while [[ -z "$opt_pid" ]] || grep -q "$opt_pid" <<< "$(ps -ef | awk '{print $2}')"; do
    ((count++))
    local pad_left=0 pad_right=0 symbol_size symbol
    symbol="${!count}"
    symbol_size="${#symbol}"
    case "$align" in
      0) pad_right=$((max - symbol_size));;
      1) pad_left=$(((max - symbol_size)/2))
         pad_right=$((max - symbol_size - pad_left));;
      2) pad_left=$((max - symbol_size));;
    esac
    echo -en "${txt//%ANIM%/"$(printf "%*s%s%*s" "$pad_left" "" "${!count}" "$pad_right" "")"}\r"
    [[ $count -eq $# ]] && count=0
    sleep "$opt_delay"
  done
  [[ $opt_newline -eq 0 ]] && echo
}
