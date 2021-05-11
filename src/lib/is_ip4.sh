#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Checks whether an entry is a valid IPv4 address.
# Params:
#   $1    <string> String to check for IPv4 address format
# Returns:
#   0/true if valid, 1/false otherwise
#------------------------------------------------------------------------------
is_ip4() {
  if grep -qE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' <<< "$1"; then
    local IFS='.'
    for p in $1; do
      [[ ${p##0} -lt 0 || ${p##0} -gt 255 ]] && return 1
    done
    unset bits
  else
    return 1
  fi
  return 0
}
