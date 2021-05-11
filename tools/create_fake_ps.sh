#! /usr/bin/env bash

# Create fake binaries which will basically do nothing but sit there being pretty.
# Will not override files unless force provided.

# Displays basic usage
usage() {
  echo "usage: $(basename "$0") [-f] [-d <basedir>] <names..>"
}

# Base directory
BASE_DIR=''
# Force override
O_FORCE=1

# Option check
while : ; do
  case "$1" in
    -d) BASE_DIR="$2"; shift;;
    -f) O_FORCE=0;;
     *) break;;
  esac
  shift
done

# Arg check
if [[ $# -lt 1 ]]; then
  echo "ERROR: wrong number of arguments." >& 2
  usage
  exit 1
fi

# Create all
for binary; do
  # Set target path
  target="$binary"
  [[ -n "$BASE_DIR" ]] && target="$BASE_DIR/$binary"
  if [[ -f "$target" ]] && [[ $O_FORCE -eq 1 ]]; then
    echo "Would override '$target' but force not provided, skipping."
    continue
  fi
  # Create file
  echo -e \
  "#! /usr/bin/env bash

while : ; do
  echo -en \"$binary \$(date)\\\\r\"
  sleep 1
done" > "$target"
  # Make it executable
  chmod +x "$target"
  echo "Created: $target"
done
