#!/usr/bin/env bash

source "$SH_PATH_LIB/log_for_level.sh"

#------------------------------------------------------------------------------
# Displays usage.
# Options:
#   -f  Shows full usage.
#------------------------------------------------------------------------------
usage() {
    echo "usage: $(basename "$0") [options] <length> <files..>"
    if [[ "$1" == "-f" ]]; then
      echo -e "with:
  length  Length to which shorten all names, extensions will be kept and not included in the size.
  files   All files to process.
Options:
  -h, --help      Displays this message.
  -p, --preserve  Preserves the original files (copy instead of rename).
  -s, --silent    Silent mode (overrides verbose).
  -t, --text      Length will be deducted from the length of the first argument, not the number.
                  Ex: 'abcd' will be length 4.
  -v, --verbose Verbose mode (overrides silent)."
    fi
}

#------------------------------------------------------------------------------
# Renames all provided files to the given length.
# Params:
#   $1    Length
#   $*    All files to rename
#------------------------------------------------------------------------------
rename_all_to_length() {
  local length
  length="$1"
  shift
  logl 0 "$#"
  for file; do
    dir="$(dirname "$file")"
    name="$(basename "$file")"
    ext="${name##*.}"
    [[ -n "$ext" ]] && name="${name%.*}"
    new_name="$(echo "$name" | head -c "$length")"
    [[ -n "$ext" ]] && new_name="${new_name}.$ext"
    if [[ $o_preserve -eq 1 ]]; then
      mv --backup=numbered "${OP_ARGS[@]}" "$file" "$dir/$new_name"
    else
      cp --backup=numbered "${OP_ARGS[@]}" "$file" "$dir/$new_name"
    fi
    logl -n '.'
  done
}

o_preserve=1
LOGLEVEL=1 # 0 = silent, 1 = normal, 2 = verbose
o_text_for_size=1

# Parse options
while : ; do
  case "$1" in
    -h|--help) usage -f; exit 0;;
    -p|--preserve) o_preserve=0;;
    -s|--silent) LOGLEVEL=2;;
    -t|--text) o_text_for_size=0;;
    -v|--verbose) LOGLEVEL=0;;
     *) break;;
  esac
  shift
done

# Args control
if [[ $# -lt 2 ]]; then
    echo "ERROR[$(basename "$0")]: wrong number of arguments." >& 2
    usage
    exit 1
fi

length="$1"
if [[ $o_text_for_size -eq 0 ]]; then
  length="${#length}"
fi
re='^[0-9]+$'
if ! [[ "$length" =~ $re ]] ; then
   echo "ERROR[$(basename "$0")]: Length provided (\$1) is not a number." >&2
   exit 1
fi
OP_ARGS=(--force)
[[ $LOGLEVEL -eq 0 ]] && OP_ARGS+=("-v")

rename_all_to_length "$length" "${@:2}"

