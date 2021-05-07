#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Converts all files of given extension to wanted extensions via "magick".
# Args:
#   $1    Directory with all images to convert
#   $2    Format of source images
#   $3    Desired format for target images
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
  if [[ $# -lt 3 ]]; then
    echo "ERROR: Wrong number of arguments." >& 2
    echo "usage: <dir> <src-format> <tgt-format>"
    return 1
  fi
  while read file; do
    magick convert "$file" "${file//".$2"/".$3"}"
  done < <(find "$1"  -maxdepth 1 -mindepth 1 -type f -name "*.$2")
}
