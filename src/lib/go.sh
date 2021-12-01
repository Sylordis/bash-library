#! /usr/bin/env bash

# Includes
source "$SH_PATH_LIB/to_upper.sh"

#------------------------------------------------------------------------------
# Changes the directory according to a local dynamic location or HOME variable.
# They should be according to the form: {VAR}_HOME.
# You can also declare dynamic pathes which will hold a command that go will
# execute, every path being a variable named GO_DYN_PATH_{NAME}. Dynamic paths
# are checked before home variables and will override them if having the same
# name/var.
# Params:
#   $1    <location> Name of the LOCATION or HOME variable.
#  [$*]   <suffixes..> Path suffix for home variables that Will be added to path
#           each argument being a directory or additional arguments to provide to
#           dynamic paths.
#------------------------------------------------------------------------------
go() {
  if [[ $# -eq 0 ]]; then
    echo "ERROR[$FUNCNAME]: Nowhere to go sir!" >& 2
    echo "Usage: go <location> [suffixes..]"
    return 1
  else
    # Getting location var
    local loc=""
    local dyn_path
    dyn_path="$(declare -p "GO_DYN_PATH_$(to_upper "$1")"  2> /dev/null)"
    if [[ -n "$dyn_path" ]]; then
      # Dynamic path: get the path from an expression
      loc="GO_DYN_PATH_$(to_upper "$1")"
      loc="$(eval "${!loc}" "${@:2}")"
    else
      # Usual: get the HOME variable
      loc="$(to_upper "$1")_HOME"
      loc="${!loc}"
    fi
    # Check the given location
    if [[ -n "$loc" ]] && [[ -d "$loc" ]]; then
      local path="$loc"
      # Add arguments as folders except if it's a dynamic path
      if [[ -z "$dyn_path" ]]; then
        local arg
        for arg in "${@:2}"; do
          path+="/$arg"
        done
      fi
      # shellcheck disable=SC2164
      cd "$path"
    else
      if [[ -n "$loc" ]] && [[ ! -d "$loc" ]]; then
        # Doesn't exist (physical)
        echo "ERROR[$FUNCNAME]: Location '$loc' does not exist." >& 2
      else
        # Doesn't exist (software)
        echo "ERROR[$FUNCNAME]: Location '$1' not set nor valid." >& 2
      fi
      return 1
    fi
  fi
}
