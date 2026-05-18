#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Converts all files of given extension to wanted extensions via "magick".
# Params:
#   $1    <format-in> Format of source images (extension)
#   $2    <format-out> Desired format for target images (extension)
#   $*    <dirs> Directories containing files to convert
# Options:
#   -d, --delete  Deletes source after conversion
#   -s, --silent  Silent mode, do not output anything
#   -bgblack, -bgwhite
#                 For alpha to non-alpha format, will fill the alpha parts of
#                 the image with the given colour.
#------------------------------------------------------------------------------
convert_all_to_format() {
  local file o_delete=1 o_silent=1 _o_bg
  _log() { echo -e "$@"; }
  _usage() { echo "usage: ${FUNCNAME[1]} [-d] [-s] [-bg<white|black>] <format-in> <format-out> <dirs..>"; }
  while : ; do
    case "$1" in
      -d|--delete) o_delete=0;;
      -s|--silent) _log() { :; }; o_silent=0;;
      -bgblack|-bgwhite) _o_bg="${1##-bg}" ;;
      -h|--help) _usage; return 0;;
      *) break;;
    esac
    shift
  done
  # Check for magick binary
  if [[ -z "$(which magick)" ]]; then
    echo "ERROR[$FUNCNAME]: 'magick' command not available." >& 2
    return 1
  fi
  # Arg check
  if [[ $# -lt 3 ]]; then
    echo "ERROR[$FUNCNAME]: Wrong number of arguments." >& 2
    _usage
    return 1
  fi
  # Convert
  local from to line_length max_cols count index total max_str size end_str
  _magic_args=()
  [[ -n "${_o_bg}" ]] && _magic_args+=("-background" "${_o_bg}" "-flatten" "-alpha" "off")
  from="$1"
  to="$2"
  line_length=$(tput cols)
  for dir in "${@:3}"; do
    count=1
    index=0
    total=$(find "$dir" -maxdepth 1 -mindepth 1 -type f -name "*.$from" 2> /dev/null | wc -l)
    max_str=" $total/$total"
    max_cols=$(((line_length - ${#max_str}) / 10))
    _log "${dir}:"
    while read -r file; do
      if magick "$file" "${_magic_args[@]}" "${file//".$from"/".$to"}"; then
        [[ $o_delete -eq 0 ]] && rm --preserve-root "$file"
        if [[ $o_silent -eq 1 ]]; then
          end_str="$count/$total"
          ((index++))
          size=$((line_length - index - 1))
          if [[ $index -ge $((max_cols * 10)) ]]; then
              echo
              ((index-= max_cols * 10))
          fi
          printf '\r%s%*s' "$(printf ".%0.s" $(seq -s ' ' 1 "$index"))" "$size" "$end_str"
        fi
      fi
      ((count++))
    done < <(find "$dir" -maxdepth 1 -mindepth 1 -type f -name "*.$from")
    if [[ "$total" -eq 0 ]]; then
      _log "No files to convert."
    else
      _log ""
    fi
  done
  unset _log _usage _magic_args
}
