#! /bin/bash

#------------------------------------------------------------------------------
# Finds all directories at a given path and list them in natural order.
# Automatically excludes the dot folder, do not list sub-directories.
# Params:
#   $1    Path where to search for directories
#  [$2]   Folder names to exclude
# Returns:
#   A list of paths
#------------------------------------------------------------------------------
find_dirs() {
  # Wrong usage
  if [[ $# -eq 0 ]]; then
    echo "usage: find_dirs <path> [folders-exclusion..]"
    return 1
  fi
  # Go to path
  cd "$1" 2> /dev/null
  # Exit if directory doesn't exist
  if [[ $? -ne 0 ]]; then
    echo "Directory $1 doesn't exist"
    return 1
  fi
  local command='find . -maxdepth 1 -type d'
  # Generate excludes
  local exc
  for exc in "${@:2}"; do
    command="$command ! -name '$exc'"
  done
  # Finish the command
  command="$command ! -name '.' | sed 's/[./]//g' | sort"
  eval "$command"
}
