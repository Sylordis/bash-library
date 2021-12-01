#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Displays an animated fish.
# Params:
#  [$1]   [length] Total line length to fill (default=terminal columns)
# Options:
#   -pid <PID>  PID of the program to wait for
#------------------------------------------------------------------------------
animation_fish() {
  local line_length pid direction curr_pos fish_index
  animations_right=("><(((°>" "}<(((°>" "=<(((°>")
  # shellcheck disable=SC2034
  animations_left=("<°)))><" "<°)))>{" "<°)))>=")
  direction=right
  curr_pos=0
  pause=0.2
  while : ; do
    case "$1" in
      -pid) pid="$2"; shift;;
         *) break;;
    esac
    shift
  done
  line_length="$1"
  [[ -z $line_length ]] && line_length=$(tput cols)
  while [[ -z "$pid" ]] || grep -q "$pid" <<< "$(ps -ef | awk '{print $2}')"; do
    # Check borders
    if [[ "$direction" == right ]] && \
        [[ $((curr_pos+${#animations_right[fish_index]})) -ge $line_length ]]; then
      direction=left
    elif [[ "$direction" == left ]] && [[ $curr_pos -le 1 ]]; then
      direction=right
    fi
    local left fish right fish_size
    local -n curr_anim_array="animations_$direction"
    left=""
    fish="${curr_anim_array[$((curr_pos % ${#curr_anim_array[@]}))]}"
    fish_size="${#fish}"
    right=""
    case "$direction" in
      left) ((curr_pos--));;
      right) ((curr_pos++));;
    esac
    [[ $curr_pos -gt 1 ]] && left="$(printf "%$((curr_pos-1))s")"
    [[ $((curr_pos+fish_size)) -lt $((line_length-1)) ]] && \
        right="$(printf "%$((line_length-curr_pos-fish_size))s")"
    echo -ne "$left$fish$right\r"
    sleep $pause
  done
  unset animations_right animations_left
}
