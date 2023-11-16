#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Copies files from the source to target directory and adds prefix or suffix.
# Without --prefix or --suffix, it is preferable to only use cp command.
#
# Args:
#   $*    <sources..>  Source files to copy
#   $last <target>  Target where to copy the files
#
# Options:
#   -v      Verbose mode (outputs cp verbose).
#   --prefix=<mode[:format]>
#   --suffix=<mode[:format]>
#       Will copy the files by assigning a prefix/suffix to each file.
#     mode=number
#       Each file will be prefixed/suffixed by an increasing number (starting at 1).
#       Format of the number can be specified with alphanumeric characters, and
#       a separator can be specified at the end (either - or _).
#       ex: --prefix=numbered:xxx_ will prefix with 3 digits format,
#       padding with 0s and with a "_" separator.
#     mode=Any other
#       Considers the mode as simple text that will be appened as prefix.
#------------------------------------------------------------------------------
copy_files_affix() {
  # Default printing methods
  _opt_prefix_fnc() { : ; }
  _opt_suffix_fnc() { : ; }
  # Helper method
  _get_numbered_affix_format() {
    local aff aff_format aff_sep
    # Reset array
    unset affix_format
    if [[ "$1" == *':'* ]]; then
      # Figure out format
      aff_format="${1##*:}"
      # Get separator (first one available)
      aff_sep="$(grep -Eo -e "[_-]" <<< "$aff_format" | head -1)"
      # If separator, remove last character
      [[ -n "$aff_sep" ]] && aff_format="${aff_format::-1}"
      # Check if padding to be added
      if [[ -n "$aff_format" ]]; then
        aff_format="%0${#aff_format}i"
      else
        aff_format="%i"
      fi
      aff="${1%%:*}"
    else
      aff="$1"
      aff_format="%i"
    fi
    affix_format=("$aff" "$aff_format" "$aff_sep")
  }
  # Options parsing
  local opt_verbose
  local opt_prefix opt_prefix_format opt_prefix_sep
  local opt_suffix opt_suffix_format opt_suffix_sep
  while : ; do
    case "$1" in
        --prefix=*) opt_prefix="${1##--prefix=}";;
        --suffix=*) opt_suffix="${1##--suffix=}";;
        -v) opt_verbose="-v";;
        *) break;;
    esac
    shift
  done
  # Args parsing
  if [[ $# -lt 2 ]]; then
    echo "ERROR[$FUNCNAME]: Not enough arguments."
    return 1
  fi
  # Solve affixes and redefine affixes method
  affix_format=()
  case "$opt_prefix" in
    numbered*) _get_numbered_affix_format "$opt_prefix"
                read -r opt_prefix opt_prefix_format opt_prefix_sep <<< "${affix_format[@]}"
               _opt_prefix_fnc() { printf "${opt_prefix_format}%s" "$1" "${opt_prefix_sep}"; }
               ;;
    *) _opt_prefix_fnc() { printf "%s" "${opt_prefix}"; }
  esac
  affix_format=()
  case "$opt_suffix" in
    numbered*)  _get_numbered_affix_format "$opt_suffix"
                read -r opt_suffix opt_suffix_format opt_suffix_sep <<< "${affix_format[@]}"
               _opt_suffix_fnc() { printf "%s${opt_suffix_format}" "${opt_suffix_sep}" "$1"; }
               ;;
    *) _opt_suffix_fnc() { printf "%s" "${opt_suffix}"; }
  esac
  # Process files
  local file file_basename file_newname target i=1
  prefix_args=()
  suffix_args=()
  target="${*: -1}"
  for file in "${@:1:$#-1}"; do
    # Set affixes arguments according to their mode
    case "$opt_prefix" in
        numbered) prefix_args=("$i");;
    esac
    case "$opt_suffix" in
        numbered) suffix_args=("$i");;
    esac
    file_basename="$(basename "$file")"
    file_newname="$(_opt_prefix_fnc "${prefix_args[@]}")${file_basename}$(_opt_suffix_fnc "${suffix_args[@]}")"
    cp -r $opt_verbose "$file" "$target/$file_newname"
    ((i++))
  done
  # Cleaning
  unset _get_numbered_affix_format
  unset prefix_args _opt_prefix_fnc suffix_args _opt_suffix_fnc
}
