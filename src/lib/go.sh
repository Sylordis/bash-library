#! /bin/bash

# Includes
source "$SH_PATH_LIB/in_array.sh"
source "$SH_PATH_LIB/to_upper.sh"

#------------------------------------------------------------------------------
# Changes the directory according to a local dynamic location or HOME variable.
# They should be according to the form: {VAR}_HOME.
# You can also declared an array of dynamic pathes, called GO_DYN_PATHS,
# where every value is linked to a variable GO_DYN_PATH_{VALUE} which is a
# command to execute.
# Params:
#   $1    Name of the LOCATION or HOME variable.
#  [$*]   Path suffix. Will be added to path, each argument being a directory.
#------------------------------------------------------------------------------
go() {
  if [[ $# -eq 0 ]]; then
    echo "Nowhere to go sir!" >& 2
    echo "Usage: go <location> [args]"
    return 1
  else
    # Getting location var
    local loc=""
    if in_array "$1" "${GO_DYN_PATHS[@]}"; then
      # Dynamic path: get the path from an expression
      loc="GO_DYN_PATH_$(to_upper "$1")"
      loc="$(eval "${!loc} ${*:2}")"
    else
      # Usual: get the HOME variable
      loc="$(to_upper "$1")_HOME"
      loc="${!loc}"
    fi
    # Check the given location
    if [[ -n "$loc" ]] && [[ -d "$loc" ]]; then
      local path="$loc"
      # Add arguments as folders except if it's a dynamic path
      if ! in_array "$1" "${GO_DYN_PATHS[@]}"; then
        local arg
        for arg in "${@:2}"; do
          path+="/$arg"
        done
      fi
      cd "$path"
    else
      if [[ -n "$loc" ]] && [[ ! -d "$loc" ]]; then
        # Doesn't exist (physical)
        echo "ERROR: Location '$loc' does not exist." >& 2
      else
        # Doesn't exist (software)
        echo "ERROR: Location '$1' not set nor valid." >& 2
      fi
      return 1
    fi
  fi
}
