#! /usr/bin/env bash

# This script will distribute (or delete) a file at the same path on every given hosts.
# It does not check if the target directory exists or not nor if the hosts are reachable.
# Dependencies: scp,ssh

#------------------------------------------------------------------------------
# Displays basic usage
# Options:
#     -f    Displays full usage.
#------------------------------------------------------------------------------
usage() {
  echo "usage: $(basename "$0") [-d] [-t <target>] <hosts..> -- <files..>"
  if [[ "$1" == '-f' ]]; then
  echo "  with:
    hosts
      Hostnames or IP addresses (can specify user as in ssh commands).
    files
      Paths to files to transfer.
  options:
    -d
      Deletes the given files.
    -h, --help
      Prints this help message.
    -t <target>
      Changes the dirpath of the files on the target hosts."
  else
    echo "       Use option --help for full usage."
  fi
}

# Variables
CLEAN=1
SSH_OPTIONS=(-o "ConnectTimeout=5" -o "BatchMode=yes" -o "StrictHostKeyChecking=no")
HOSTS=()
FILES=()
TARGET=''

#------------------------------------------------------------------------------
# Populates lists of hosts and files.
#------------------------------------------------------------------------------
create_hosts_lists() {
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

#------------------------------------------------------------------------------
# Performs distribution or cleaning.
#------------------------------------------------------------------------------
distribute() {
  local host file filepath
  for host in "${HOSTS[@]}"; do
    for file in "${FILES[@]}"; do
      if [[ -n "$TARGET" ]]; then
        filepath="$TARGET/$(basename "$file")"
      else
        filepath="$(readlink -f "$file")"
      fi
      if [[ $CLEAN -eq 0 ]]; then
        ssh "${SSH_OPTIONS[@]}" "$host" "rm --preserve-root -rf $filepath"
      else
        scp -r "${SSH_OPTIONS[@]}" "$file" "${host}:$filepath"
      fi
    done
  done
}

# Option parsing
while :; do
  case "$1" in
    -d) CLEAN=0;;
    -h|--help) usage -f; exit 0;;
    -t) TARGET="$2"; shift;;
     *) break;;
  esac
  shift
done

create_hosts_lists "$@"

# Sanity checks
if [[ ${#HOSTS[@]} -eq 0 ]] || [[ ${#FILES[@]} -eq 0 ]]; then
  echo "ERROR: Wrong number of arguments." >& 2
  usage
  exit 1
fi

distribute
