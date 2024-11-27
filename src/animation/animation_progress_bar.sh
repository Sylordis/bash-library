#! /usr/bin/env bash

# Includes
source "$SH_PATH_LIB/strip_color_tags.sh"
source "$SH_DEBUG"

#------------------------------------------------------------------------------
# Displays a progress bar on one whole line. Successive calls of this function
# will erase previous bar if it's still on the same line, except when it reaches
# completion (100%), where it will display a new line instead.
# Params:
#   $1    <bar>
#           Format of progress bar, with beginning, progress, filling and
#           ending characters. Filling character is optional and default is
#           white space.
#           ex: `[=]`   will output `[===     ]`
#               `[#=]`  will output `[###=====]`
#               `[# ]`  will output `[###     ]` (similar to `[#]`)
#               `[#-]`  will output `[###-----]`
#   $2    <current> Current amount
#   $3    <total>   Total amount
#  [$4]   [length]
#           Length of the line (in characters). Default is length of the
#           terminal (`tput cols`).
# Options:
#   -%, --percent
#     Display total percentages after the bar, counts in total length
#   -c, --count
#     Display item count, current and max, after the bar. Counts in total
#     length.
#   -cf <CODE>, --color-filling <CODE>
#     Adds a colour code to the filling characters when displaying. You can
#     use multiple colour codes with `<CODE1>;<CODE2>;...`.
#   -cp <CODE>, --color-progress <CODE>
#     Adds a colour code to the progress characters when displaying. You can
#     use multiple colour codes with `<CODE1>;<CODE2>;...`.
#   -i <TXT>, --item <TXT>
#       Creates a wide display with an item (TXT) on the left and the progress
#       bar on the right. If there's not enough space to display the item and
#       the bar, the item's text will be truncated. This option makes this
#       method print on the whole terminal length, but the bar size will be
#       limited to <length>, which should be provided. When using items, the
#       prefix will not be counted in the bar size.
#   -n, --no-newline
#     Do not display a new line if reaching completion but go back to
#     line beginning.
#   -p <MSG>, --prefix <MSG>
#     Prefix before bar, counts in total length (unless --item).
# Example:
#   progress_bar "[=]" 80 13 560
# Dependencies:
#   echo, printf, tput
#------------------------------------------------------------------------------
animation_progress_bar() {
  local o_color_filling="" \
    o_color_progress="" \
    o_item="" \
    o_no_new_line=1 \
    o_prefix="" \
    o_show_step_count=1 \
    o_show_percentages=1
  # Option parsing
  while : ; do
    case "$1" in
     -%|--percent) o_show_percentages=0;;
     -c|--count) o_show_step_count=0;;
     -cp|--color-progress) o_color_progress="$2"; shift;;
     -cf|--color-filling) o_color_filling="$2"; shift;;
     -i|--item) o_item="$2"; shift;;
     -n|--no-newline) o_no_new_line=0;;
     -p|--prefix) o_prefix="$2"; shift;;
      *) break;;
    esac
    shift
  done
  # Arg check
  if [[ $# -lt 3 ]]; then
    # Just return as error if not enough argument
    echo "ERROR[$FUNCNAME]: Wrong number of arguments." >& 2
    return 1
  fi
  local format="$1"
  local current_amount="$2"
  local corrected_amount="$2"
  local total_amount="$3"
  local available_size
  if [[ $# -gt 3 ]]; then
    available_size="$4"
  else
    available_size="$(tput cols)"
  fi
  local error=1
  # Check input
  if [[ "${#format}" -ne 3 ]] && [[ "${#format}" -ne 4 ]]; then
    echo "ERROR[$FUNCNAME]: Format (\$1) must be 3 or 4 characters (ex: '[=]' or '[#-]')." >& 2
    error=0
  fi
  if ! [[ "$current_amount" =~ ^[0-9]+$ ]]; then
    echo "ERROR[$FUNCNAME]: Current amount (\$2) must be a positive integer." >& 2
    error=0
  fi
  if ! [[ "$total_amount" =~ ^[0-9]+$ ]]; then
    echo "ERROR[$FUNCNAME]: Total amount (\$3) must be a positive integer." >& 2
    error=0
  fi
  if ! [[ "$available_size" =~ ^[0-9]+$ ]] || [[ "$available_size" -lt $((3+${#o_prefix})) ]]; then
    echo "ERROR[$FUNCNAME]: Line length (\$4) must be an integer greater than 3 + prefix size." >& 2
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
    bar_size="$((available_size-2))"
    if [[ -n "$o_prefix" ]] && [[ -z "$o_item" ]]; then
      stripped_prefix="$(strip_color_tags "$o_prefix")"
      stripped_prefix_size="${#stripped_prefix}"
      bar_size="$((available_size - stripped_prefix_size))"
    fi
    [[ $o_show_percentages -eq 0 ]] && bar_size="$((bar_size - 5))"
    if [[ $o_show_step_count -eq 0 ]]; then
      single_items_size="${#total_amount}"
      items_size="$((single_items_size * 2 + 2))"
      bar_size="$((bar_size - items_size))"
    fi
    [[ "$current_amount" -gt "$total_amount" ]] && corrected_amount="$total_amount"
    filling_size="$((bar_size * corrected_amount / total_amount))"
    # Prepare normal display string
    local bar_string=""
    [[ -z "$o_item" ]] && bar_string="$o_prefix"
    bar_string="${bar_string}${begin_char}"
    [[ -n "$o_color_progress" ]] && bar_string="${bar_string}\e[${o_color_progress}m"
    bar_string="${bar_string}$(printf "%${filling_size}s" | tr ' ' "$filling_char")"
    [[ -n "$o_color_progress" ]] && bar_string="${bar_string}\e[0m"
    if [[ "$corrected_amount" -ne "$total_amount" ]]; then
      [[ -n "$o_color_filling" ]] && bar_string="${bar_string}\e[${o_color_filling}m"
      bar_string="${bar_string}$(printf "%$((bar_size-filling_size))s" | tr ' ' "$space_char")"
      [[ -n "$o_color_filling" ]] && bar_string="${bar_string}\e[0m"
    fi
    bar_string="${bar_string}${end_char}"
    # Prepare optional strings
    [[ $o_show_step_count -eq 0 ]] && bar_string="${bar_string} $(printf "%d/%d" "$current_amount" "$total_amount")"
    if [[ "$o_show_percentages" -eq 0 ]]; then
      local percentage="$((100 * current_amount / total_amount))"
      bar_string="${bar_string} $(printf "%4s" "$percentage%")"
    fi
    # Prepare new line
    if [[ "$corrected_amount" -eq "$total_amount" ]] && [[ "$o_no_new_line" -eq 1 ]]; then
      bar_string="${bar_string}\n"
    else
      bar_string="${bar_string}\r"
    fi
    # Display
    if [[ -n "$o_item" ]]; then
      local terminal_size item_available_size item_string ellipsis prefix_string
      terminal_size=$(tput cols)
      prefix_size=0
      if [[ -n "$o_prefix" ]]; then
        prefix_size=${#o_prefix}
        prefix_size=$((prefix_size + 2))
        prefix_string=" ${o_prefix} "
      fi
      item_available_size=$((terminal_size - available_size - prefix_size))
      item_string="$o_item"
      if [[ $item_available_size -lt ${#o_item} ]]; then
        item_available_size=$((item_available_size-5))
        item_string="${item_string:0:$item_available_size}"
        ellipsis="[...]"
      fi
      echo -en "$(printf "%-${item_available_size}s${ellipsis}%${prefix_size}s%${available_size}s" "$item_string" "$prefix_string" "$bar_string")"
    else
      echo -en "$bar_string"
    fi
  else
    return 1
  fi
}
