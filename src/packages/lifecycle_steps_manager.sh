#!/usr/bin/env bash

#==============================================================================
# This package manages the ordering of the lifecycle of an application through
# an ordered list of steps and different profiles (being specific common steps).
# It functions on several variables:
#   - LIFECYCLE_ALL_STEPS
#   - LIFECYCLE_PROFILES
#   - LIFECYCLE_STEPS
# Find description of said variables at their declaration.
# You'll only need to call lifecycle_manage_steps method once with the proper
# arguments.
#==============================================================================

#------------------------------------------------------------------------------
# Gets the index of a value in an array.
# Params:
#   $1    <needle> value to search for
#   $*    <haystack..> values of the array
# Returns:
#   the index of the first occurence of the value in the array, or -1 if it
#   cannot be found.
#------------------------------------------------------------------------------
find_in_array() {
  local v i=-1 c=0
  for v in "${@:2}"; do
    [[ "$1" == "$v" ]] && { i=$c; break; }
    ((c++))
  done
  echo $i
}

#------------------------------------------------------------------------------
# Checks if a value is contained in an array.
# Params:
#   $1    <needle> the value to search for
#   $*    <haystack..> all the values to search in
#         Don't forget to surround this argument by quotes to prevent bash
#         expansion of values (especially while using star-character.)
# Returns:
#   0/true if the value is in the array, 1/false otherwise
#------------------------------------------------------------------------------
in_array() {
  local v
    # Loop through the haystack
  for v in "${@:2}"; do
    # Value found, return true
    [[ "$v" == "$1" ]] && return 0
  done
  # Value not found, return false
  return 1
}

# List containing all steps available, ordered by execution priority.
LIFECYCLE_ALL_STEPS=()
# List of steps that, if called in a profiled manner, will trigger all previous
# steps listed in said list.
LIFECYCLE_PROFILES=()
# list that will be used by the script and contain the resulting list of
# steps to be performed.
LIFECYCLE_STEPS=()

#------------------------------------------------------------------------------
# Manages lifecycle steps by populating LIFECYCLE_STEPS.
# Only the profile with the biggest number of steps will be retained.
# Steps not wanted in a profile can be removed with '-name'. Steps not part of
# profiles can be added just by using their names and will be added according
# to lifecycle steps order.
# Example:
#     with lifecycle steps 'sort compile build test nuke'
#             and profiles 'compile build test'
#     one could provide parameters 'sort test -build' to have it resulting to
#     a final steps list of 'sort compile test.'
#     'sort test -build' is equivalent to '+sort test -build'.
# Options:
#   --log <cmd> Logger command, default is 'echo ERROR[$FUNCNAME]'
#               If replaced, pattern %FUNCNAME% can be used to be replaced by
#               the actual function name.
# Args:
#   $*  Any steps/profile name
# Returns:
#   ES0 if configuration went fine and LIFECYCLE_STEPS has been populated.
#   ES1 if any error happened during configuration.
#------------------------------------------------------------------------------
lifecycle_manage_steps() {
  local arg
  local ps_ret=0
  local _logger="echo ERROR[$FUNCNAME]"
  # Set logger
  if [[ "$1" == '--log' ]]; then
    _logger="${2//'%FUNCNAME%'/$FUNCNAME}"
    shift 2
  fi
  # Check that steps exists
  if [[ ${#LIFECYCLE_ALL_STEPS[@]} -eq 0 ]]; then
    $_logger "No steps configured (LIFECYCLE_ALL_STEPS)." >& 2
    ps_ret=1
  fi
  # Check that all profiles are steps
  for arg in "${LIFECYCLE_PROFILES[@]}"; do
    if ! in_array "$arg" "${LIFECYCLE_ALL_STEPS[@]}"; then
      $_logger "Unknown profile '$arg' is not referenced in steps." >& 2
      ps_ret=1
    fi
  done
  # If previous checks failed
  [[ $ps_ret -ne 0 ]] && return $ps_ret
  local wanted_profile filtered_arg
  _steps_add=()
  _steps_remove=()
  _steps_profile=()
  # Parse arguments
  for arg; do
    # Validate argument
    filtered_arg="$(tr -d -- '-+' <<< "$arg")"
    if in_array "$filtered_arg" "${LIFECYCLE_ALL_STEPS[@]}"; then
      case "$arg" in
        -*) _steps_remove+=("$filtered_arg");;
        +*) _steps_add+=("$filtered_arg");;
         *) if ! in_array "$arg" "${LIFECYCLE_PROFILES[@]}"; then
              _steps_add+=("$arg")
            # Replace wanted profile only if it includes more steps than a
            # previously set one
            elif [[ -n "$wanted_profile" ]] && \
                  [[ $(find_in_array "$arg" "${LIFECYCLE_PROFILES[@]}") -gt $(find_in_array "$wanted_profile" "${LIFECYCLE_PROFILES[@]}") ]]; then
              wanted_profile="$arg"
            else
              wanted_profile="$arg"
            fi;;
      esac
    else
      # Unknown profile/step
      $_logger "Unknown profile/step '"$arg"'." >& 2
      ps_ret=1
    fi
  done
  # Check if wanted step is given
  if [[ $ps_ret -eq 0 ]] && [[ -z "$wanted_profile" ]] \
      && [[ ${#_steps_add[@]} -eq 0 ]] \
      && [[ ${#_steps_remove[@]} -eq 0 ]]; then
    $_logger "No profile/steps given to perform." >& 2
    ps_ret=1
  fi
  # If no error, proceed to build the steps list
  if [[ $ps_ret -eq 0 ]]; then
    local step_index=$(find_in_array "$wanted_profile" "${LIFECYCLE_PROFILES[@]}")
    # Get all steps from profile
    _steps_profile=(${LIFECYCLE_PROFILES[@]:0:$((step_index+1))})
    # Create steps list
    for arg in "${LIFECYCLE_ALL_STEPS[@]}"; do
      # Add step if provided in steps to add or not removed from the profile
      if in_array "$arg" "${_steps_add[@]}" || \
          ( in_array "$arg" "${_steps_profile[@]}" \
            && ! in_array "$arg" "${_steps_remove[@]}" ); then
        LIFECYCLE_STEPS+=("$arg")
      fi
    done
  fi
  unset _steps_add _steps_remove _steps_profile
  return $ps_ret
}
