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
    rm -rf "$TEST_WORKING_DIR/"*
  fi
}
# Shortcut aliases
WD_clean() { working_directory_clean "$@"; }

#------------------------------------------------------------------------------
# Creates test files in the working directory. Also deletes any previous working
# directory created.
# Params:
#   $*    Files to create in the working directory
#  [-d]   Files after this flag will be created as directories
#  [-f]   Files after this flag will be created as empty files
#------------------------------------------------------------------------------
working_directory_create() {
  local dir=1
  working_directory_delete
  if [[ ! -d "$TEST_WORKING_DIR" ]]; then
    TEST_WORKING_DIR="$(mktemp -d "$TEST_WORKING_DIR.XXXX")"
    if [[ ! -d "$TEST_WORKING_DIR" ]]; then
      echo "ERROR[$FUNCNAME]: working directory cannot be created" >& 2
      exit 1
    fi
  fi
  cd "$TEST_WORKING_DIR"
  local var
  for var; do
    case "$var" in
     -d) dir=1 ;;
     -f) dir=0 ;;
      *) if [[ "$dir" -eq 1 ]]; then
           mkdir -p "$var"
         else
           touch "$var"
         fi;;
    esac
    shift
  done
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
# Params:
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
# Prints a tree of the working directory.
# Options:
#   -d    Prints directories only
#------------------------------------------------------------------------------
working_directory_print() {
  (
    cd "$TEST_WORKING_DIR"
    tree -aC "$@"
  )
}
# Shortcut aliases
WD_print() { working_directory_print "$@"; }
WD_tree() { working_directory_print "$@"; }
