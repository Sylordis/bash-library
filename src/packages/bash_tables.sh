#! /bin/bash

#==============================================================================
# Use this package to print nicely printed tables in bash.
# Always use table_configure first to configure the next table(s) and then use
# table_print_line to print each line and table_print_separator to print
# separator lines.
#==============================================================================

# Configuration variables

readonly _TABLE_PRINT_JOIN='+'
readonly _TABLE_PRINT_LINE='-'
readonly _TABLE_PRINT_SIDE='|'
_TABLE_CFG_BORDER=0
_TABLE_CFG_COL_ALIGN=()
_TABLE_CFG_GLOBAL_ALIGN='left'
_TABLE_CFG_PAD=1
_TABLE_CFG_SIZES=()
_TABLE_CFG_WIDTH=${TABLE_DEFAULT_SIZE-$(tput cols)}
shopt -s extglob

#------------------------------------------------------------------------------
# Configures the table to be printed.
# Flags: order does matter
#   MISC:
#     --new         resets all configuration for a new table
#   BORDERS: default is with border. Border is included in the size.
#     -border[=]<v> with <v> = 1/"none"/"no" or 0/"yes".
#                   Sets the fact that the table will have a border or not.
#    --no-border    Removes the borders of the table (eq. -border=none),
#   COLUMNS AND SIZE:
#         -c[=]<c>
#     -cols[=]<c>   with <c> size of columns separated by commas, * for adapt,
#                   if ncols is defined and cols do not give enough columns,
#                   additional columns will be adapted.
#                   ex: -cols=20,30,*,60
#     -ncols[=]<x>  with <x> the number of columns.
#     --size[=]<w> or --width[=]<w>
#                   with <w> the size of the table (default is `tput cols` or
#                   varaible TABLE_DEFAULT_SIZE if defined).
#    PADDING: Default is no padding.
#     -p or --padding
#                   Pads the cells with a space. This is included in the size.
#                   Default is without padding.
#   -np or --no-padding
#                   Removes padding if previously set.
#   TEXT ALIGN: default is left
#     -align[=]<v> or --<v> with <v> = left, center or right.
#     -calign[=]<v>
#                   with <v> the alignment for each column separated by commas,
#                   use * for inherit.
#                   ex: -col-align=*,*,right,*
#     -calign<n>[=]<v>
#                   with <n> the column number (starting at 0) and <v> the alignment.
#                   ex: -calign4=right
# Aliases:
#   table_cfg
#   table_config
#   table_new (includes `--new` flag)
#------------------------------------------------------------------------------
table_configure() {
  local col ncols global_align borders width calign cnalign error=0 padding
  global_align="$_TABLE_CFG_GLOBAL_ALIGN"
  col_sizes=("${_TABLE_CFG_SIZES[@]}")
  cols_aligns=("${_TABLE_CFG_COL_ALIGN[@]}")
  padding=$_TABLE_CFG_PAD
  declare -A cols_aligns_specific
  while : ; do
    case "$1" in
              --new) borders=0
                     ncols=0
                     col_sizes=()
                     width=${TABLE_DEFAULT_SIZE-$(tput cols)}
                     global_align='left'
                     cols_aligns=()
                     padding=1 ;;
              # Borders
        --borders) borders="$2"; shift ;;
      --borders=*) borders="${1##*=}" ;;
        --no-borders) borders=1 ;;
              # Columns and size
                    --cols|-c) IFS=',' read -r -a col_sizes <<< "${2}"; shift ;;
                --cols=*|-c=*) IFS=',' read -r -a col_sizes <<< "${1##*=}" ;;
                   --ncols|-n) ncols="$2"; shift ;;
               --ncols=*|-n=*) ncols="${1##*=}" ;;
 --size=*|-s=*|--width=*|-w=*) width="${1##*=}" ;;
         --size|-s|--width|-w) width="$2"; shift ;;
              # Padding
             -p|--padding) padding=0;;
         -np|--no-padding) padding=1;;
              # Text align
                --align=*) global_align="${1##*=}" ;;
                  --align) global_align="$2"; shift ;;
           --left|--right) global_align="${1##--}"; shift ;;
                 --calign) IFS=',' read -r -a cols_aligns <<< "${2}" ;;
               --calign=*) IFS=',' read -r -a cols_aligns <<< "${1##*=}" ;;
       --calign+([0-9])=*) calign="${1##*=}"
                           cnalign="${1%%=*}"
                           cnalign="${cnalign##*calign}"
                           cols_aligns_specific[$cnalign]="$calign" ;;
         --calign+([0-9])) calign="${2}"
                           cnalign="${1##*calign}"
                           cols_aligns_specific[$cnalign]="$calign"
                           shift ;;
              # Leftover
              *) [[ $# -eq 0 ]] && break
                 echo "ERROR: Unknown flag '$1'." >& 2; return 1;;
    esac
    shift
  done
  # Borders
  if [[ -n "$borders" ]]; then
    case "$borders" in
  1|n|no|none) borders=1 ;;
      0|y|yes) borders=0 ;;
          *) echo "ERROR[$FUNCNAME]: Unknown value '$borders' for table border." >& 2
             error=1 ;;
    esac
  fi
  # Columns
  if [[ ${#col_sizes[@]} -eq 0 ]] && [[ $ncols -eq 0 ]]; then
    echo "ERROR[$FUNCNAME]: No columns defined for table." >& 2
    error=1
  else
    if [[ -n "$ncols" ]] && [[ $ncols -eq 0 ]]; then
        unset ncols
    fi
    # Sum set widths
    local sumwidth=0 adaptwidth ntoadapt
    for col in "${col_sizes[@]}"; do
      if [[ "$col" != '*' ]]; then
        sumwidth=$((sumwidth + col))
      else
        ((ntoadapt++))
      fi
    done
    # Adapt remaining columns
    # Calculate number of columns to adapt
    if [[ -n "$ncols" ]] && [[ ${#col_sizes[@]} -lt $ncols ]]; then
      ntoadapt=$((ntoadapt + (ncols - ${#col_sizes[@]}) ))
    fi
    # Check current width is set, default to terminal size if not
    if [[ -z "$width" ]]; then
      width=$(tput cols)
    fi
    # Adapt new columns
    local index
    if [[ $ntoadapt -gt 0 ]]; then
      adaptwidth=$(( width - sumwidth ))
      adaptwidth=$(( adaptwidth / ntoadapt ))
      for index in $(seq 0 $((ncols - 1))); do
        if [[ $index -ge ${#col_sizes[@]} ]]; then
          col_sizes[$index]=$adaptwidth
        elif [[ "${col_sizes[$index]}" == '*' ]]; then
          col_sizes[$index]=$adaptwidth
        fi
      done
    fi
    # Adapt * columns and set alignment
    for index in $(seq 0 $((${#col_sizes[@]} - 1))); do
      [[ "${col_sizes[$index]}" == '*' ]] && col_sizes[$index]=$adaptwidth
      cols_aligns[$index]="${cols_aligns_specific[$index]-$global_align}"
    done
  fi
  # Set if all good
  if [[ error -eq 0 ]]; then
    [[ -n "$borders" ]] && _TABLE_CFG_BORDER=$borders
    _TABLE_CFG_SIZES=("${col_sizes[@]}")
    [[ -n "$width" ]] && _TABLE_CFG_WIDTH=$width
    [[ -n "$global_align" ]] && _TABLE_CFG_GLOBAL_ALIGN=$global_align
    _TABLE_CFG_COL_ALIGN=("${cols_aligns[@]}")
    _TABLE_CFG_PAD=$padding
  fi
  unset col_sizes cols_aligns_specific
  return $error
}
table_cfg() { table_configure "$@"; }
table_config() { table_configure "$@"; }
table_new() { table_configure --new "$@"; }

#------------------------------------------------------------------------------
# Prints elements formatted as table columns.
# Any element which goes over the row length will be skipped.
# Args:
#   $*    Entries to add, one per column
# Aliases:
#   table_line
#------------------------------------------------------------------------------
table_print_line() {
  local index first=0 size align arg_index txt overflow=0 lpad rpad full_txt pad
  local size_mod=0
  local border_left border_right=''
  local full_line=''
  if [[ $_TABLE_CFG_PAD -eq 0 ]]; then
    pad=' '
    size_mod=$((size_mod + 2))
  fi
  if [[ $_TABLE_CFG_BORDER -eq 0 ]]; then
    border_right="$_TABLE_PRINT_SIDE"
    size_mod=$((size_mod + 1))
  fi
  for index in $(seq 0 $((${#_TABLE_CFG_SIZES[@]}-1))); do
    full_txt=''
    border_left=''
    # Original intended size, will be modified by the borders
    size=${_TABLE_CFG_SIZES[$index]}
    size=$((size - size_mod))
    # Overflow management
    if [[ $overflow -gt 0 ]]; then
      size=$((size - overflow))
      overflow=0
    fi
    # Borders
    if [[ $_TABLE_CFG_BORDER -eq 0 ]] && [[ $first -eq 0 ]]; then
      first=1;
      border_left="$_TABLE_PRINT_SIDE"
      size=$((size - 1))
    fi
    # Alignment
    align=''
    case "${_TABLE_CFG_COL_ALIGN[$index]}" in
      left) align='-';;
    esac
    # Content
    arg_index=$((index + 1))
    txt="${!arg_index}"
    if [[ "${_TABLE_CFG_COL_ALIGN[$index]}" != "center" ]]; then
      full_txt="$(printf -- "%${align}${size}s" "$txt")"
    else
      lpad=$(( (size - ${#txt}) / 2 ))
      rpad=$(( size - ${#txt} - lpad))
      full_txt="$(printf "%${lpad}s%s%${rpad}s" ' ' "$txt" ' ')"
    fi
    # Manage overflow
    full_txt="${border_left}${pad}${full_txt}${pad}${border_right}"
    full_line+="$full_txt"
    if [[ ${#full_txt} -gt ${_TABLE_CFG_SIZES[$index]} ]]; then
      overflow=$((${#full_txt} - ${_TABLE_CFG_SIZES[$index]}))
    fi
  done
  echo -e "$full_line"
}
table_line() { table_print_line "$@"; }

#------------------------------------------------------------------------------
# Prints a separator if there's a border set to print (_TABLE_CFG_BORDER).
# Args:
#   None
# Aliases:
#   table_separator
#------------------------------------------------------------------------------
table_print_separator() {
  if [[ "$_TABLE_CFG_BORDER" -eq 0 ]]; then
    local col size first=0
    for col in "${_TABLE_CFG_SIZES[@]}"; do
      size=$((col - 1))
      if [[ "$first" -eq 0 ]]; then
          first=1
          size=$((size - 1))
          printf -- '%s' "$_TABLE_PRINT_JOIN"
      fi
      eval "printf -- '$_TABLE_PRINT_LINE%.0s' {1..$size}"
      printf -- '%s' "$_TABLE_PRINT_JOIN"
    done
    echo
  fi
}
table_separator() { table_print_separator "$@"; }
