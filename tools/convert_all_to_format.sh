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
#------------------------------------------------------------------------------
convert_all_to_format() {
  local file o_delete=1
  _log() { echo -e "$@"; }
  while : ; do
    case "$1" in
      -d|--delete) o_delete=0;;
      -s|--silent) _log() { :; };;
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
    echo 'usage: <format-in> <format-out> <dirs..>'
    return 1
  fi
  # Convert
  local from to line_length sections_count count total
  from="$1"
  to="$2"
  line_length=$(tput cols)
  sections_count=$((line_length * 10 / 11))
  for dir in "${@:3}"; do
    count=1
    total=$(find "$dir" -maxdepth 1 -mindepth 1 -type f -name "*.$from" | wc -l)
    _log "${dir}: ${total}"
    while read -r file; do
      if magick convert "$file" "${file//".$from"/".$to"}"; then
        [[ $o_delete -eq 0 ]] && rm --preserve-root "$file"
        _log -n '.'
        [[ $((count % 10)) -eq 0 ]] && _log -n '|'
        [[ $((count % sections_count )) -eq 0 ]] && _log ''
      fi
      ((count++))
    done < <(find "$dir" -maxdepth 1 -mindepth 1 -type f -name "*.$from")
  done
  unset _log
}
