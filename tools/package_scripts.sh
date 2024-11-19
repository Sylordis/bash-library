#!/usr/bin/env bash

# Creates a new version of scripts with all source commands resolved.
# This script uses temporary files and will backup all replaced files in the output
# directory, just be sure to not package files with the same name to not rewrite
# previous packaging.

source "$SH_DEBUG"
source "$SH_PATH_LIB/log.sh"

#------------------------------------------------------------------------------
# Displays basic usage.
# Options:
#   -f    Displays full usage
#------------------------------------------------------------------------------
usage() {
  echo "usage: $(basename "$0") [options] [-o <dir>] <scripts..>"
  if [[ "$1" == '-f' ]]; then
  echo "  with:
    scripts
      All scripts to package.
  options:
    --debug
      Turns on the debug mode.
    -h, --help
      Prints this help message.
    -v, --verbose
      Turns on the verbose mode.
    -o <dir>, --output <dir>
      Specify an output directory for the packaged scripts.
      Default is '$DEFAULT_DIR_DIST'."
  else
    echo "  Use option --help for full usage."
  fi
}

# Variables
DEBUG_MODE=1
VERBOSE_MODE=1
VERBOSE_OPTIONS=()
readonly DEFAULT_DIR_DIST='./dist'
# To be set via options or later
DIR_DIST='' # Default is DEFAULT_DIR_DIST

#------------------------------------------------------------------------------
# Process files by replacing source instructions.
# Args:
#   $*    All files to process.
#------------------------------------------------------------------------------
process_files() {
  local file
  for file; do
    log -v "Packaging file '$file'"
    local out_file
    out_file="$DIR_DIST/$(basename "$file")"
    # Check if file reachable
    if [[ ! -r "$file" ]]; then
      log -e "WARN: File '$file' is not reachable or readable. Skipping."
      continue
    fi
    if grep -E '^ *(source|\.) .*' "$file" | grep -qv '# *pack:noreplace'; then
      local tmp_file
      tmp_file="$(mktemp "$DIR_DIST/$(basename "$out_file").XXXXXX")"
      awk -f "$SH_PATH_SRC/awk/replace_source_files.awk" "$file" > "$tmp_file"
      mv -b "$tmp_file" "$out_file"
    else
      log -v "No sourced file in '$file'."
      mv --backup=numbered "${VERBOSE_OPTIONS[@]}" "$file" "$out_file"
    fi
    log -v "Packaged file '$out_file'."
  done
}

# Option check
while : ; do
  case "$1" in
    --debug) DEBUG_MODE=0;;
    -h|--help) usage -f; exit 0;;
    -o|--output) DIR_DIST="$2"; shift;;
    -v|--verbose) VERBOSE_MODE=0
                  VERBOSE_OPTIONS=(-v);;
     *) break;;
  esac
  shift
done

# Arg check
if [[ $# -lt 1 ]]; then
  log -e "ERROR: Wrong number of arguments."
  usage
  exit 1
fi

# Output dir
if [[ -z "$DIR_DIST" ]]; then
  DIR_DIST="$DEFAULT_DIR_DIST"
fi
# Create it if not exists
if [[ ! -d "$DIR_DIST" ]]; then
  mkdir "${VERBOSE_OPTIONS[@]}" -p "$DIR_DIST" || exit 1
else
  log -v "'$DIR_DIST' exists."
fi

process_files "$@"
