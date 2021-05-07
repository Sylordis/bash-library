#! /bin/bash

#------------------------------------------------------------------------------
# Checks whether an entry is a valid IP address.
# Params:
#   $1    IP address
# Returns:
#   0/true if valid, 1/false otherwise
#------------------------------------------------------------------------------
is_ip() {
  local flag=0
  ! grep -qE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' <<< "$1" && flag=1
  if [[ $flag -eq 0 ]]; then
    bits=(${1//./ })
    for p in "${bits[@]}"; do
      [[ $flag -eq 0 && ${p##0} -lt 0 || ${p##0} -gt 255 ]] && flag=1
    done
    unset bits
  fi
  return $flag
}
