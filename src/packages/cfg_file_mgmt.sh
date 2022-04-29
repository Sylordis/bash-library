#! /usr/bin/env bash

#==============================================================================
# This file can be sourced or included as is in a bash script.
# It contains utility method to manage configuration files made out of sections
# under the form presented underneath. All variables extracted are done via
# load_cfg_file_to_vars() method, that uses arguments "<bashvarname>=<propname>".
# ex:
# load_cfg_file_to_vars path-to-cfg-file:sectiontitle 'myvar=theproperty'
# will load the value of "theproperty" into bash variable "myvar" if the property
# exists. The type can be specified after the variable name and before the
# assignment either in the configuration file or when loading the variables by
# appending ':type' to the variable name.
# ex (config): exe.basic.sha:cmd=/some/of/path/exe_sha256.sh
# ex (load): load_cfg_file_to_vars my.cfg 'content:file=MY_CONTENT_PATH'
# See different types below. Types during load superseed types from the configuration.
#.
# If no section title is provided, then the section "default" will be loaded.
#
# Configuration files should one or multiple sections under the form:
# [section title]
# variable=value
# variable=value
# variable:type=value
# ...
#
# Sections do not have to be separated by an empty line.
# Comments can be done in the configuration file with lines starting with #.
# Dependencies:
#   awk, grep
#==============================================================================

#------------------------------------------------------------------------------
# Loads a configuration file to fill variables.
# This file is expected to be basic configuration file with blocks delimited
# by [blockname]. Each property has to be on a new line, under the form
# <varname>=<propname>.
# IMPORTANT: This method cannot set variables declared on an upper scope than
# the one it is called from.
# Params:
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
# Options:
#   --log <cmd>
#         Logger command, default is 'echo ERROR[$FUNCNAME]'
#         If replaced, pattern %FUNCNAME% can be used to be replaced by
#         the actual function name.
#   -ne   Once the configuration file is loaded, will check that all variables
#         are not set to empty value, or throws an error
# Dependencies:
#   grep
#------------------------------------------------------------------------------
cfg_load_file_to_vars() {
  local file blockname block no_empty=1
  local _logger="echo ERROR[$FUNCNAME]:"
  # Options parsing
  while : ; do
    case "$1" in
    --log) _logger="${2//'%FUNCNAME%'/$FUNCNAME}"; shift;;
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
    $_logger "File '$file' does not exist or cannot be read." >& 2
    return 1
  fi
  local file_integrity_ok=0
  # Config block check
  if ! grep -qF "[${blockname:-default}]" "$file"; then
    $_logger "No configuration found for [${blockname:default}] in '$file'." >& 2
    return 1
  else
    local block varname cfgvar cfgline cfgvalue vartype var
    declare -A all_vars
    block="$(cfg_load_block "$file" "$blockname")"
    for var in "${@:2}"; do
      cfgvar="${var%%=*}"
      varname="${var##*=}"
      vartype=''
      # Extract vartype if present
      if [[ "$varname" == *':'* ]]; then
        vartype="${varname##*:}"
        varname="${varname%%:*}"
      fi
      # Set variable
      local -n refvarname="$varname"
      cfgline="$(grep -oE "^ *$cfgvar(:[^=]+)?=.*" <<< "$block")"
      # Determine type from config file if not already set
      if [[ -z "$vartype" ]] && grep -qE "^ *$cfgvar:[^=]+=.*" <<< "$cfgline"; then
        vartype="${cfgline%%=*}"
        vartype="${vartype##*:}"
      fi
      cfgvalue="$(grep -oP "^ *$cfgvar(:[^=]+)?=\K.*" <<< "$cfgline")"
      # Check for vartype
      #shellcheck disable=SC2034
      case "$vartype" in
        file|FILE) cfgvalue="${cfgvalue/#~/$HOME}"
                  [[ -r "${cfgvalue}" ]] && refvarname="$(cat "${cfgvalue}")";;
          cmd|CMD) refvarname="$(eval "${cfgvalue}")";;
                *) refvarname="$cfgvalue";;
      esac
      all_vars[$varname]="$cfgvar"
    done
    # Post processing checkup
    for var in "${!all_vars[@]}"; do
      if [[ $no_empty -eq 0 ]] && [[ -z "${!var}" ]]; then
        $_logger "'$var' not set (property '${all_vars[$var]}')." >& 2
        file_integrity_ok=1
      fi
    done
    # Final check if error
    if [[ $file_integrity_ok -eq 1 ]]; then
      $_logger "Loading '$file' resulted in incomplete variable setting." >& 2
    fi
    unset all_vars
  fi
  return $file_integrity_ok
}

#------------------------------------------------------------------------------
# Loads a configuration file block identified by a name. If no name is specified,
# then the block "default" will be loaded.
# Comments starting with # will be ignored.
# Params:
#   $1    File where to extract the block from
#  [$2]   Block name ("default" if not specified)
# Dependencies:
#   awk, grep
#------------------------------------------------------------------------------
cfg_load_block() {
  awk 'BEGIN { RS="[[]"; } /^'"${2:-default}"'\]/ { print "[" $0 }' "$1" \
    | grep -v "^#"
}
