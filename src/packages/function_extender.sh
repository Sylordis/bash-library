#! /usr/bin/env bash

#==============================================================================
# This file can be sourced or included as is in a bash script.
# Function extension is used to simply "extend functions". An extended function
# is created as a separate function but can be launched according to context.
# Simply create the function you want to extend and its extension, but in the
# former just call the method
#   launch_function_extension "$FUNCNAME" <extension-name> "$@"
# An extension is usually designed to receive the same arguments as the function
# it extends (hence the "$@"), but it does not have to be an absolute rule.
# This package requires a variable FNC_EXT_NAME_PATTERN to be set, as a pattern
# for extended method names.
#==============================================================================

#------------------------------------------------------------------------------
# apply_transformations()
# Applies multiple transformations to a text, given the name of the required
# methods to apply. The methods have to accept the text as first argument.
# Params:
#   $1    Text to transform
#   $*    Methods to apply for transformation
# Returns:
#   The transformed text
#------------------------------------------------------------------------------
apply_transformations() {
  local original="$1"
  local fnc
  for fnc in "${@:2}"; do
    eval "original=\"\$($fnc \"$original\")\""
  done
  echo "$original"
}

#------------------------------------------------------------------------------
# check_function_exists()
# Checks if a function is defined.
# Params:
#   $1    Name of the function
# Returns:
#   0/true if the function is defined, 1/false otherwise
#------------------------------------------------------------------------------
check_function_exists() {
  local typecheck
  typecheck="$(type -t "$1" 2> /dev/null)"
  #shellcheck disable=SC2181
  [[ $? -eq 0 ]] && [[ "$typecheck" == "function" ]]
}

#------------------------------------------------------------------------------
# check_var_set()
# Checks if a variable is set or not, meaning if it does contain something.
# Params:
#   $1    Variable name
# Returns:
#   0/true if it does exist, 1/false otherwise
#------------------------------------------------------------------------------
check_var_set() {
  if [[ -z "${!1}" ]]; then
    echo "ERROR: Variable '$1' not set" >&2
    return 1
  fi
  return 0
}

#------------------------------------------------------------------------------
# to_lower()
# Changes all characters in a string to lowercase.
# Apply any color tags after applying this method.
# Params:
#   $*    Any string
# Returns:
#   The lowercased string.
#------------------------------------------------------------------------------
to_lower() {
  tr '[:upper:]' '[:lower:]' <<< "$@"
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PACKAGE FUNCTION_EXTENDER
# Shared requirements:
#   - Variable set: FNC_EXT_NAME_PATTERN
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#------------------------------------------------------------------------------
# function_extender.get_function_extension_name()
# Simply replaces the sub-patterns in the general pattern to get the extension
# name.
# Requires:
#   @link shared_requirements PACKAGE FUNCTION_EXTENDER
# Params:
#   $1    Basic function name
#   $2    Extension name
#------------------------------------------------------------------------------
get_function_extension_name() {
  local replacement_base replacement_ext final_cmd
  # Replace for base
  replacement_base="$(get_extender_pattern_value base "$1")"
  # Replace for extension
  replacement_ext="$(get_extender_pattern_value ext "$2")"
  # Replace in global pattern for final expression
  final_cmd="$(echo "$FNC_EXT_NAME_PATTERN" | sed -re "s/$(get_extender_pattern base)/$replacement_base/g" -e "s/$(get_extender_pattern ext)/$replacement_ext/g")"
  unset all_base all_ext
  echo "$final_cmd"
}

#------------------------------------------------------------------------------
# function_extender.get_extender_core()
# Returns the correct text formated for the core variable.
# Params:
#   $1    Part of the pattern to consider {base, ext}, case insensitive.
#------------------------------------------------------------------------------
get_extender_core() {
  local core
  case "$(to_lower "$1")" in
    base) core="BASE";;
     ext) core="EXT";;
       *) echo "ERROR[$FUNCNAME]: unknown core variable '$1'." >&2
          exit 1
          ;;
  esac
  echo "$core"
}

#------------------------------------------------------------------------------
# function_extender.get_extender_pattern()
# Returns the pattern for the core variable.
# Params:
#   $1    Part of the pattern to consider {base, ext}, case insensitive.
#------------------------------------------------------------------------------
get_extender_pattern() {
  echo "%$(get_extender_core "$1")[^%]*%"
}

#------------------------------------------------------------------------------
# function_extender.get_extender_pattern_value()
# Takes a pattern from the function extender and gets the real value, applying
# all transformations needed.
# Requires:
#   @link shared_requirements PACKAGE FUNCTION_EXTENDER
# Params:
#   $1    Part of the pattern to consider {base, ext}, case insensitive.
#   $2    Basic function name
#------------------------------------------------------------------------------
get_extender_pattern_value() {
  local core patt declaration replacement
  core="$(get_extender_core "$1")"
  patt="$(get_extender_pattern "$1")"
  declaration="$(grep -o "$patt" <<< "$FNC_EXT_NAME_PATTERN" | sed -re "s/%([^%]+)%/\1/g")"
  elements=($(echo "${declaration##"${core}"}" | tr : ' '))
  replacement="$(apply_transformations "$2" "${elements[@]}")"
  unset elements
  echo "$replacement"
}

#------------------------------------------------------------------------------
# function_extender.get_function_extensions()
# Gets all extensions of a function according to pattern variable.
# Requires:
#   @link shared_requirements PACKAGE FUNCTION_EXTENDER
# Params:
#   $1    Basic function name
#------------------------------------------------------------------------------
get_function_extensions() {
  local replacement_base replacement_ext extensions_pattern
  replacement_base="$(get_extender_pattern_value base "$1")"
  replacement_ext="$(get_extender_pattern_value ext "[a-z_]+")"
  extensions_pattern="$(echo "$FNC_EXT_NAME_PATTERN" | sed -re "s/$(get_extender_pattern base)/$replacement_base/g" -e "s/$(get_extender_pattern ext)/$replacement_ext/g")"
  typeset -f | grep -E -o "$extensions_pattern"
}

#------------------------------------------------------------------------------
# function_extender.launch_function_extension()
# Launches a command extension, based on an 'eval' expression which will use
# a FNC_EXT_NAME_PATTERN variable.
# This pattern can contain several sub-patterns:
#     %BASE%    Base name of the function
#     %EXT%     Name of the extension
# A sub-pattern result can be modified by appending methods in the sub-pattern
# with the character ':'. This have to be the name of an existing function, which
# will be launched using an 'eval' command. Those methods have to return a value
# with an 'echo'.
#     ex: %EXT:to_lower%
# Requires:
#   @link shared_requirements PACKAGE FUNCTION_EXTENDER
# Params:
#   $1    Basic function name
#   $2    Extension name
#   $*    Function extension's arguments
# Returns:
#   The return of the extension, or just 1 if a problem happens during the
#   the launch.
#------------------------------------------------------------------------------
launch_function_extension() {
  check_var_set FNC_EXT_NAME_PATTERN || return 1
  # Arg check
  if [[ $# -lt 2 ]]; then
    echo "ERROR[$FUNCNAME]: Wrong number of arguments." >&2
    return 1
  fi
  local cmd
  cmd="$(get_function_extension_name "$1" "$2")"
  if ! check_function_exists "$cmd"; then
    echo "ERROR[$FUNCNAME]: Program not set for extension '$cmd' of feature '$1'" >&2
    return 1
  fi
  eval "$cmd ${*:3}"
}
