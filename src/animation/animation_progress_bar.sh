#! /usr/bin/env bash

# Includes
source "$SH_PATH_LIB/strip_color_tags.sh"

#------------------------------------------------------------------------------
# Displays a progress bar on one whole line. Successive calls of this function
# will erase previous bar if it's still on the same line, except when it reaches
# completion (100%), whhere it will display a new line instead.
# Params:
#   $1    <bar> Format of progress bar, with beginning, fillings and ending
#         characters.
#         Default end filling character is white space
#         ex: `[=]`   will output `[===     ]`
#             `[#=]`  will output `[###=====]`
#             `[# ]`  will output `[###     ]`
#             `[#-]`  will output `[###-----]`
#   $2    <current> Current amount
#   $3    <total> Total amount
#  [$4]   [length] Length of the line (in characters)
# Options:
#   -%          Display total show_percentages after the bar, counts in total length
#   -n          Do not display a new line if reaching completion but go back to
#               line beginning.
#   -p <MSG>    Prefix before bar, counts in total length
# Example:
#   progress_bar "[=]" 80 13 560
#------------------------------------------------------------------------------
animation_progress_bar() {
  local prefix=""
  local show_percentages=1
  local no_new_line=1
  # Option parsing
  while : ; do
    case "$1" in
     -%) show_percentages=0;;
     -n) no_new_line=0;;
     -p) prefix="$2"; shift;;
      *) break;;
    esac
    shift
  done
  # Arg check
  if [[ $# -ge 3 ]]; then
    local format="$1"
    local current_amount="$2"
    local corrected_amount="$2"
    local total_amount="$3"
    local size
    if [[ $# -gt 3 ]]; then
      size="$4"
    else
      size="$(tput cols)"
    fi
    local error=1
    # Check input
    if [[ "${#format}" -ne 3 ]] && [[ "${#format}" -ne 4 ]]; then
      echo "ERROR[$FUNCNAME]: Format (\$1) must be 3 or 4 characters (ex: '[=]' or '[#-]')." >& 2
      error=0
    fi
    if ! [[ "$size" =~ ^[0-9]+$ ]] || [[ "$size" -lt $((3+${#prefix})) ]]; then
      echo "ERROR[$FUNCNAME]: Line length (\$2) must be an integer greater than 3 + prefix size." >& 2
      error=0
    fi
    if ! [[ "$current_amount" =~ ^[0-9]+$ ]]; then
      echo "ERROR[$FUNCNAME]: Current amount (\$3) must be a positive integer." >& 2
      error=0
    fi
    if ! [[ "$total_amount" =~ ^[0-9]+$ ]]; then
      echo "ERROR[$FUNCNAME]: Total amount (\$4) must be a positive integer." >& 2
      error=0
    fi
    # No error, let's proceed
    if [[ "$error" -eq 1 ]]; then
      local begin_char filling_char space_char end_char
      # Total space that can be filled
      begin_char="${format:0:1}"
      filling_char="${format:1:1}"
      space_char=" "
      [[ "${#format}" -eq 4 ]] && space_char="${format:2:1}"
      end_char="${format:$((${#format}-1)):1}"
      local stripped_prefix stripped_prefix_size bar_size filling_size
      stripped_prefix="$(strip_color_tags "$prefix")"
      stripped_prefix_size="${#stripped_prefix}"
      bar_size="$((size-2-stripped_prefix_size))"
      [[ "$show_percentages" -eq 0 ]] && bar_size="$((bar_size-5))"
      [[ "$current_amount" -gt "$total_amount" ]] && corrected_amount="$total_amount"
      filling_size="$((bar_size*corrected_amount/total_amount))"
      echo -en "$prefix$begin_char"
      echo -en "$(printf "%${filling_size}s" | tr ' ' "$filling_char")"
      [[ "$corrected_amount" -ne "$total_amount" ]] && \
          echo -en "$(printf "%$((bar_size-filling_size))s" | tr ' ' "$space_char")"
      echo -en "$end_char"
      # Show percentages
      if [[ "$show_percentages" -eq 0 ]]; then
        local percentage="$((100*current_amount/total_amount))"
        echo -en "$(printf "%5s" "$percentage%")"
      fi
      # New line only when complete
      if [[ "$corrected_amount" -eq "$total_amount" ]] && [[ "$no_new_line" -eq 1 ]]; then
        echo ""
      else
        echo -en "\r"
      fi
    else
      return 1
    fi
  else
    # Just return as error if not enough argument
    echo "ERROR[$FUNCNAME]: Wrong number of arguments." >& 2
    return 1
  fi
}
