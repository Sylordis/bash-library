#! /bin/bash

# This script will distribute (or delete) a file at the same path on every given hosts.
# It does not check if the target directory exists or not.

# Displays basic usage
usage() {
  echo "usage: $(basename "$0") [-d] [-t <target>] <hosts..> -- <files..>"
}

# Variables
CLEAN=0
SSH_OPTIONS="-o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no"
HOSTS=()
FILES=()
TARGET=''

# Populates lists of hosts and files.
create_lists() {
  local v is_host=0
  for v; do
    if [[ "$v" == '--' ]]; then
      is_host=1
    elif [[ $is_host -eq 0 ]]; then
      HOSTS+=("$v")
    else
      FILES+=("$v")
    fi
  done
}

# Performs distribution or cleaning.
distribute() {
  local host file filepath
  for host in "${HOSTS[@]}"; do
    for file in "${FILES[@]}"; do
      if [[ -n "$TARGET" ]]; then
        filepath="$TARGET/$(basename "$file")"
      else
        filepath="$(readlink -f "$file")"
      fi
      if [[ $CLEAN -eq 1 ]]; then
        ssh $SSH_OPTIONS "$host" "rm --preserve-root -rf $filepath"
      else
        scp -r $SSH_OPTIONS "$file" "${host}:$filepath"
      fi
    done
  done
}

# Option parsing
while :; do
  case "$1" in
    -d) CLEAN=1;;
    -t) TARGET="$2"; shift;;
     *) break;;
  esac
  shift
done

create_lists "$@"

# Sanity checks
if [[ ${#HOSTS[@)]} -eq 0 -or ${#FILES[@]} -eq 0 ]]; then
  echo "ERROR: Wrong number of arguments." >& 2
  usage
  exit 1
fi

distribute
