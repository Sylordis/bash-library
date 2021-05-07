#! /bin/bash

#------------------------------------------------------------------------------
# animation_moving_bar()
# Displays an animated bar which will move horizontally back and forth.
# This animation is performed on a single line and does not echo a new line
# when killed, but goes back at the beginning of the line each time.
# Params: 
#  [$1]   Total line length to fill
# Options:
#   -p <T>      Duration between each rotation change (default 0.05)
#   -pid <PID>  PID of the program to wait for
#   -f <V>      Format of the bar
#------------------------------------------------------------------------------
animation_moving_bar() {
  # Variables
  local bar_length format line_length pause pid error
  format="[=]"
  bar_length=3
  bar_length_minimum=$((bar_length+4))
  line_length=80
  pause=0.05
  pid=""
  # Option parsing
  while : ; do
    case "$1" in
      -f) format="$2"; shift;;
      -p) pause="$2"; shift;;
    -pid) pid="$2"; shift;;
       *) break;;
    esac
    shift
  done
  line_length="$1"
  [[ -z "$line_length" ]] && line_length="$(tput cols)"
  # Processing of data
  error=1
  if [[ "${#format}" -ne 3 ]] && [[ "${#format}" -ne 4 ]]; then
    echo "ERROR[$FUNCNAME]: Format (\$1) must be 3 or 4 characters (ex: '[=]' or '[#-]')." >& 2
    error=0
  fi
  if grep -qE '[^0-9]' <<< "$line_length"; then
    echo "ERROR[$FUNCNAME]: Line length should be a number."
    error=0
  elif [[ "$line_length" -lt $bar_length_minimum ]]; then
    echo "ERROR[$FUNCNAME]: Line length should be at least $bar_length_minimum long."
    error=0
  fi
  # Display or exit
  if [[ $error -eq 1 ]]; then
    # Prepare all data for printing
    local begin_char filling_char space_char end_char curr_pos direction
    curr_pos=0
    direction=right
    begin_char="${format:0:1}"
    filling_char="${format:1:1}"
    space_char=" "
    [[ "${#format}" -eq 4 ]] && space_char="${format:2:1}"
    end_char="${format:$((${#format}-1)):1}"
    # Eternal loop
    while [[ -z "$pid" ]] || grep -q "$pid" <<< "$(ps -ef | awk '{print $2}')"; do
      # Check borders
      if [[ "$direction" == right ]] && [[ $curr_pos -ge $((line_length-1-bar_length)) ]]; then
        direction=left
      elif [[ "$direction" == left ]] && [[ $curr_pos -le 1 ]]; then
        direction=right
      fi
      case "$direction" in
        left) ((curr_pos--));;
        right) ((curr_pos++));;
      esac
      # Print
      local first second third remaining end_limit
      first=""
      second="$(printf "%${bar_length}s" | tr ' ' "$filling_char")"
      third=""
      remaining=0
      end_limit=$((line_length-1-bar_length))
      if [[ $curr_pos -gt 1 ]]; then
        first="$(printf "%$((curr_pos-1))s" | tr ' ' "$space_char")"
      fi
      if [[ $curr_pos -lt $end_limit ]]; then
        remaining=$((line_length-1-bar_length-curr_pos))
        third="$(printf "%${remaining}s" | tr ' ' "$space_char")"
      fi
      echo -ne "$begin_char$first$second$third$end_char\r"
      sleep $pause
    done
    fill_line $line_length ' '
  else
    return 1
  fi
}