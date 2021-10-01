#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Converts all files of given extension to wanted extensions via "magick".
# Params:
#   $1    <dir> Directory with all images to convert
#   $2    <format-in> Format of source images (extension)
#   $3    <format-out> Desired format for target images (extension)
# Options:
#   --delete  Deletes source after conversion
#------------------------------------------------------------------------------
convert_all_to_format() {
  local file o_delete
  while : ; do
    case "$1" in
      --delete) o_delete=0;;
      *) break;;
    esac
    shift
  done
  # Check for magick binary
  if [[ -z "$(which magick)" ]]; then
    echo "ERROR[$FUNCNAME]: 'Magick' command not available." >& 2
    return 1
  fi
  # Arg check
  if [[ $# -lt 3 ]]; then
    echo "ERROR[$FUNCNAME]: Wrong number of arguments." >& 2
    echo 'usage: <dir> <format-in> <format-out>'
    return 1
  fi
  # Convert
  while read file; do
    magick convert "$file" "${file//".$2"/".$3"}"
    # Delete if option set
    [[ $o_delete -eq 0 ]] && rm --preserve-root "$file"
  done < <(find "$1"  -maxdepth 1 -mindepth 1 -type f -name "*.$2")
}
