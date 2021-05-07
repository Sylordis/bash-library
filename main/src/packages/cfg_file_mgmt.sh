#!/usr/bin/env bash

#==============================================================================
# This file can be sourced or included as is in a bash script.
# It contains utility method to manage configuration files made out of sections
# under the form presented underneath. All variables extracted are done via
# load_cfg_file_to_vars() method, that uses arguments "<bashvarname>=<propname>".
# ex:
# load_cfg_file_to_vars path-to-cfg-file:sectiontitle 'myvar=theproperty'
# will load the value of "theproperty" into bash variable "myvar" if the property
# exists
#.
# If no section title is provided, then the section "default" will be loaded.
#
# Configuration files should one or multiple sections under the form:
# [section title]
# variable=value
# variable=value
# ...
#
# Sections do not have to be separated by an empty line.
# Comments can be done in the configuration file with lines starting with #.
#==============================================================================

#------------------------------------------------------------------------------
# Loads a configuration file to fill variables.
# This file is expected to be basic configuration file with blocks delimited
# by [blockname]. Each property has to be on a new line, under the form
# <varname>=<propname>.
# IMPORTANT: This method cannot set variables declared on an upper scope than
# the one it is called from.
# Options:
#   -ne   Once the configuration file is loaded, will check that all variables
#         are not set to empty value, or throws an error
# Args:
#   $1    Path to configuration file
#         This argument can be composed as <path>:<blockname>
#         If no blockname is specified, the entry [default] will be considered
#   $*    Variables operation under the pattern:
#         <cfg-var>=<bash-variable>[:<type>]
#         Different types:
#         - file    the content of the file will be used as value
#         - cmd     the result of the command will be used as value. This script
#                   does not manage the output of the command or any possible
#                   nor error control
#------------------------------------------------------------------------------
cfg_load_file_to_vars() {
  local file blockname block no_empty=1
  # Options parsing
  while : ; do
    case "$1" in
      -ne) no_empty=0;;
        *) break;;
    esac
    shift
  done
  if [[ "$1" == *":"* ]]; then
    file="${1%%:*}"
    blockname="${1##*:}"
  else
    file="$1"
    blockname="default"
  fi
  # File readability check
  if [[ ! -r "$file" ]]; then
    echo "ERROR: File does not exist or cannot be read." >& 2
    return 1
  fi
  local file_integrity_ok=0
  # Config block check
  if ! grep -qF "[${blockname:-default}]" "$file"; then
    echo "ERROR: No configuration found for [${blockname:default}] in '$file'." >& 2
    return 1
  else
    local name_opts block varname cfgvar value vartype
    declare -A all_vars
    block="$(cfg_load_block "$file" "$blockname")"
    for var in "${@:2}"; do
      cfgvar="${var%%=*}"
      varname="${var##*=}"
      vartype=""
      # Extract vartype if present
      if [[ "$varname" == *':'* ]]; then
        vartype="${varname##*:}"
        varname="${varname%%:*}"
      fi
      # Set variable
      local -n refvarname="$varname"
      value="$(grep -oP "^ *$cfgvar=\K.*" <<< "$block")"
      # Check for vartype
      case "$vartype" in
        file|FILE) value="${value/#~/$HOME}"
                  [[ -r "${value}" ]] && refvarname="$(cat "${value}")";;
          cmd|CMD) refvarname="$(eval "${value}")";;
                *) refvarname="$value";;
      esac
      all_vars[$varname]="$cfgvar"
    done
    # Post processing checkup
    for var in "${!all_vars[@]}"; do
      if [[ $no_empty -eq 0 ]] && [[ -z "${!var}" ]]; then
        echo "ERROR: '$var' not set (property '${all_vars[$var]}')." >& 2
        file_integrity_ok=1
      fi
    done
    # Final check if error
    if [[ $file_integrity_ok -eq 1 ]]; then
      echo "ERROR: Loading '$file' resulted in incomplete variable setting." >& 2
    fi
    unset all_vars
  fi
  return $file_integrity_ok
}

#------------------------------------------------------------------------------
# Loads a configuration file block identified by a name. If no name is specified,
# then the block "default" will be loaded.
# Comments starting with # will be ignored.
# Args:
#   $1    File where to extract the block from
#  [$2]   Block name ("default" if not specified)
#------------------------------------------------------------------------------
cfg_load_block() {
  awk 'BEGIN { RS="[[]"; } /^'"${2:-default}"'\]/ { print "[" $0 }' "$1" \
    | grep -v "^#"
}
