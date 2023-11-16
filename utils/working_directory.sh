#! /usr/bin/env bash

#==============================================================================
# This helper is used to create a test working directory where all files needed
# for the test are created and modified.
#==============================================================================

# Base path for working directory, to be modified as a temporary folder when
# calling the create method.
TEST_WORKING_DIR="/tmp/bash_wd"

#------------------------------------------------------------------------------
# Deletes all the files in the working directory but not the directory itself
#------------------------------------------------------------------------------
working_directory_clean() {
  if [[ -d "$TEST_WORKING_DIR" ]]; then
    rm -rf --preserve-root "${TEST_WORKING_DIR:?}/"*
  fi
}
# Shortcut aliases
WD_clean() { working_directory_clean "$@"; }

#------------------------------------------------------------------------------
# Creates test files in the working directory.
# Args:
#   $*    Files to create in the working directory
#  [-d]   Files after this flag will be created as directories
#  [-f]   Files after this flag will be created as empty files
#------------------------------------------------------------------------------
working_directory_add() {
  cd "$TEST_WORKING_DIR" || return 1
  local var
  for var; do
    case "$var" in
     -d) dir=0 ;;
     -f) dir=1 ;;
      *) if [[ "$dir" -eq 0 ]]; then
           mkdir -p "$var"
         else
           touch "$var"
         fi;;
    esac
    shift
  done
}
# Shortcut alias
WD_add() { working_directory_add "$@"; }

#------------------------------------------------------------------------------
# Deletes previous working directory and creates a new one.
# Args:
#   $*    Files to create in the working directory
#  [-d]   Files after this flag will be created as directories
#  [-f]   Files after this flag will be created as empty files
# See:
#   working_directory_add
#   working_directory_delete
#------------------------------------------------------------------------------
working_directory_create() {
  local dir=0
  working_directory_delete
  if [[ ! -d "$TEST_WORKING_DIR" ]]; then
    TEST_WORKING_DIR="$(mktemp -d "$TEST_WORKING_DIR.XXXX")"
    if [[ ! -d "$TEST_WORKING_DIR" ]]; then
      echo "ERROR[$FUNCNAME]: working directory cannot be created" >& 2
      exit 1
    fi
  fi
  working_directory_add "$@"
}
# Shortcut alias
WD_create() { working_directory_create "$@"; }

#------------------------------------------------------------------------------
# Deletes the working directory along with all files in it.
#------------------------------------------------------------------------------
working_directory_delete() {
  if [[ -d "$TEST_WORKING_DIR" ]]; then
    rm -rf "$TEST_WORKING_DIR"
  fi
}
# Shortcut aliases
WD_delete() { working_directory_delete "$@"; }
WD_del() { working_directory_delete "$@"; }

#------------------------------------------------------------------------------
# Returns the working directory path.
# Args:
#   $1    File name to be append to the path of the working directory
#------------------------------------------------------------------------------
working_directory_get_path() {
  echo -n "$TEST_WORKING_DIR"
  if [[ $# -ne 0 ]]; then
    echo "/$1"
  else
    echo
  fi
}
# Shortcut aliases
WD_get_path() { working_directory_get_path "$@"; }
WD_path() { working_directory_get_path "$@"; }

#------------------------------------------------------------------------------
# Prints the working directory (through find)
# Options:
#   -d      Prints directories only
#   -f      Print files only
#------------------------------------------------------------------------------
working_directory_print() {
  local find_args
  while : ; do
    case "$1" in
      -d) find_args='-type d';;
      -f) find_args='-type f';;
       *) break;;
    esac
    shift
  done
  (
    cd "$TEST_WORKING_DIR"
    find . $find_args -not -name '.'
  )
}
# Shortcut aliases
WD_print() { working_directory_print "$@"; }

#------------------------------------------------------------------------------
# Prints a tree of the working directory.
# Options:
#   -d      Prints directories only
#------------------------------------------------------------------------------
working_directory_tree() {
  (
    cd "$TEST_WORKING_DIR"
    tree -aC "$@"
  )
}
# Shortcut alias
WD_tree() { working_directory_tree "$@"; }
