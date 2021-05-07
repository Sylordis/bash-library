#! /bin/bash

# All declared mocks
declare -A MOCKS

#------------------------------------------------------------------------------
# Removes all non supported caracters from a string.
# Params:
#   $*    Text to normalize
# Returns:
#   The normalized text.
#------------------------------------------------------------------------------
_normalise_text() {
  echo "$@" | tr ' ' '_' | tr -c -d '[:alnum:]._-'
}

#------------------------------------------------------------------------------
# Checks if a mock is defined in the mocks table.
# Params:
#   $1    Normalized name of the mock
#------------------------------------------------------------------------------
mocks_check_if_exists() {
  [[ ${MOCKS["$1"]+abc} ]]
}

#------------------------------------------------------------------------------
# Creates a temporary file to test instead of the real function, transforming:
#   - '/dev/tty'            => '/dev/stdout'
#   - 'read -p <MSG>..'     => 'echo "<MSG>"; read ..'
# This mock's path can be recovered by using the method mock_test_get_tty().
# After the test, all mocks are automatically deleted.
# Params:
#   $1    File to mock
#   $2    Identifier you want to give to the mock, it will be normalized
#   $*    Operations you want to mock, in this given list: tty read
# Returns:
#   Nothing but sets a variable with the path to the new file,  which can be
#   called by using the function get_test_mock_tty()
#------------------------------------------------------------------------------
mocks_create() {
  local file="$1"
  local id
  id="$(_normalise_text "$2")"
  shift 2
  if [[ -f "$file" ]]; then
    # Delete if it already exists
    mocks_delete "$id" "WARNING: Redefining mock '$2'."
    # (Re)Create it
    local tmp_file
    tmp_file="$(mktemp "/tmp/$id.XXXXXXXXXXX")"
    cp "$file" "$tmp_file"
    MOCKS[$id]="$tmp_file"
    mocks_transform "$id" "$@"
  fi
}

#------------------------------------------------------------------------------
# Deletes one mock if it exists, removing the temporary file in the process.
# Params:
#   $1    Identifier of the mock
#  [$2]   Message to display if the mock already exists
#------------------------------------------------------------------------------
mocks_delete() {
  local id
  id="$(_normalise_text "$1")"
  if mocks_check_if_exists "$id"; then
    [[ $# -gt 1 ]] && echo "${@:2}" > /dev/tty
    rm "${MOCKS[$id]}" 2> /dev/null
    unset MOCKS[$id]
  fi
}

#------------------------------------------------------------------------------
# Deletes all mocks at once.
#------------------------------------------------------------------------------
mocks_delete_all() {
  # Delete temporary files
  for mock in "${!MOCKS[@]}"; do
    rm "${MOCKS[$mock]}"
    unset MOCKS[$mock]
  done
}

#------------------------------------------------------------------------------
# Recovers the path to a mock of tty.
# Params:
#   $1    Identifier of the mock
# Returns:
#   The path of the mock, or throws an error if it does not exist.
#------------------------------------------------------------------------------
mocks_get() {
  local id
  id="$(_normalise_text "$1")"
  if mocks_check_if_exists "$id"; then
    echo "${MOCKS[$id]}"
  else
    echo "ERROR: trying to get unexisting mock '$1'." >& 2
    exit 1
  fi
}

#------------------------------------------------------------------------------
# Does an operation on a mock by transforming it.
# Params:
#   $1    Identifier of the mock
#   $*    Operations to do on the mock
#           Values: tty read
#------------------------------------------------------------------------------
mocks_transform() {
  local id
  id="$(_normalise_text "$1")"
  for op; do
    case "$op" in
     read) sed -i -re 's/read -p ("[^"]+") (.*)/echo \1\nread \2/g' "${MOCKS[$id]}";;
      tty) sed -i -re 's|/dev/tty|/dev/stdout|g' "${MOCKS[$id]}";;
    esac
  done
}

# Trap for an interrupted exit
interrupt_exit() {
  mocks_delete_all
}
trap interrupt_exit INT
