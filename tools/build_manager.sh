#!/usr/bin/env bash

# Libraries inclusion
source "$SH_DEBUG"
source "$SH_PATH_LIB/check_function_exists.sh"
source "$SH_PATH_PACKS/logging_helper.sh"
source "$SH_PATH_PACKS/lifecycle_steps_manager.sh"

#------------------------------------------------------------------------------
# This script is used to manage building and the lifecycle of an application and
# serves as a skeleton for build managers. It acts as a hub from where to launch
# sub scripts or methods..
# See usage() for arguments and options.
#------------------------------------------------------------------------------

#==============================================================================
# GLOBAL METHODS
#==============================================================================

#------------------------------------------------------------------------------
# Displays basic usage
#------------------------------------------------------------------------------
usage() {
  echo "usage: $(basename "$0") [options] <profile/steps..>
       $(basename "$0") help <topic/step>"
  if [[ "$1" == '-f' ]]; then
    echo "  Available steps (in order):
    ${LIFECYCLE_ALL_STEPS[@]}
  Available profiles:
    ${LIFECYCLE_PROFILES[@]}"
    echo "  with options:
    -c <path> or --config <path>
      Specifies a configuration file. Default is './build_manager.cfg'.
    --continue-on-error
      Execution of step sequence does not end if one returns in error
    -b <branch> or --branch <branch>
      Specifies the branch to work on. Default is 'development'.
    -h or --help
      Displays this message.
    --list
      Alls listed steps as arguments will be added as is if they exist. No ordering
      will be performed on them.
    -v <version> or --version <version>
      Sets the software version.
    -w <path> or --workspace <path>
      Sets the working directory where all repositories are."
  else
    echo "    Run with -h or --help to get full usage."
  fi
}

#==============================================================================
# VARIABLES
#==============================================================================

# Pattern for files to be launched by this build manager.
# Use %STEP% to include the name of the current step.
readonly BUILD_MNGER_STEP_FILE_PATT='my_%STEP%.sh'
# Pattern for steps that only require a simple function to be run.
# Use %STEP% to include the name of the current step.
readonly BUILD_MNGER_STEP_FNC_PATT='my_%STEP%'
# All possible steps in logical execution order
readonly LIFECYCLE_ALL_STEPS=('clone' 'clean' 'branch' 'pull' 'compile' 'test' \
 'build' 'release' 'rpms' 'medias' 'tag' 'obfuscate')
# Steps descriptions, ordered alphabetically
declare -A LIFECYCLE_STEP_DESC
LIFECYCLE_STEP_DESC['branch']='Sets the working branch.'
LIFECYCLE_STEP_DESC['build']='Build the OPF project.'
LIFECYCLE_STEP_DESC['clean']='Clean all artefacts.'
LIFECYCLE_STEP_DESC['clone']='Clone all repositories to a workspace.'
LIFECYCLE_STEP_DESC['compile']='Perform a compilation of the project.'
LIFECYCLE_STEP_DESC['medias']='Creates release medias (ISOs).'
LIFECYCLE_STEP_DESC['obfuscate']='Obfuscate any sensitive data in repositories (usernames, passwords) for data to be shipped.'
LIFECYCLE_STEP_DESC['pull']='Pull latest changes.'
LIFECYCLE_STEP_DESC['release']='Create a full OPF release'
LIFECYCLE_STEP_DESC['rpms']='Create rpm files.'
LIFECYCLE_STEP_DESC['tag']='Create a new tag for the version and pushes it.'
LIFECYCLE_STEP_DESC['test']='Run all unit tests of the project.'
# Profiles that can be selected (from steps)
readonly LIFECYCLE_PROFILES=( 'compile' 'test' 'build' 'release' 'rpms' 'medias' 'tag' )
# Branch upon which to perform processing
REPO_BRANCH='development'
# Software version?
SOFTWARE_VERSION=''
# Directory containing the build manager and other build scripts
BUILD_MANAGER_DIR="$(readlink -f "$(dirname "$0")")"
# Workspace that contains all repositories (including this one)
# Default is the script's location's grand-parent.
BUILD_MANAGER_WORKSPACE=""
# Path to config file
CONFIG_FILE="build_manager.cfg"
# Option: following steps will continue if the previous ended on error
O_CONTINUE_ON_ERROR=1
# Option: provided steps are a straight up list
O_STEPS_LIST=1

#==============================================================================
# SPECIFIC METHODS
#==============================================================================

#------------------------------------------------------------------------------
# Provides help text on different topics.
# If help is demanded on a step, either implement the paragraph below, otherwise
# the script will look for the usage method of said step's script. This feature
# is using temporary files for extracting and sourcing such method.
# Arguments:
#   $1    Topics for help, either 'steps', 'profiles' or a step name
#------------------------------------------------------------------------------
help() {
  local ps_ret=0
  if in_array "$1" 'steps' 'profiles'; then
   echo "Description of single steps/profiles:"
   local key
   for key in "${!LIFECYCLE_STEP_DESC[@]}"; do
     printf '  %-15s' "$key"
     echo "${LIFECYCLE_STEP_DESC[$key]}"
   done
   echo "Profiles
  A profile is a step in the following list.
    > ${LIFECYCLE_PROFILES[@]}
  Running a profile will trigger all previous profiles steps that are in the list
up to the one wanted.
  For example, running profile '${LIFECYCLE_PROFILES[3]}' will trigger the following steps:
    > ${LIFECYCLE_PROFILES[@]:0:4}
Run 'help' with a specific step/profile name to get the usage of this step."
  # elif in_array "$1" 'mystep'; then
  # Here you should put the usage of this particular step's function
  elif in_array "$1" "${LIFECYCLE_ALL_STEPS[@]}"; then
    local exec tmp_usage_file step_encoded
    step_encoded=$(tr ' ' '-' <<< "$1")
    exec_name="${BUILD_MNGER_STEP_FILE_PATT//'%STEP%'/$1}"
    exec="$BUILD_MANAGER_DIR/$exec_name"
    if [[ -f "$exec" ]]; then
      # Create the temporary file by extracting usage method in step file
      tmp_usage_file="$(mktemp 'tmp_usage.XXXX.sh')"
      sed -n '/^usage\(\)/,/^}/p' "$exec" > "$tmp_usage_file"
      if [[ -n "$(cat "$tmp_usage_file")" ]]; then
        # Rename the method usage to something else
        local usage_method="_help_usage_${step_encoded}"
        sed -i -e "s/usage()/${usage_method}()/g" "$tmp_usage_file"
        # Source file then delete it
        source "$tmp_usage_file"
        # Run temp usage method
        if check_function_exists "$usage_method"; then
          $usage_method -f
        else
          log_error "Couldn't run usage method of '$exec_name'."
          ps_ret=1
        fi
      else
        log_error "Couldn't find 'usage' method for step '$1' ($(basename "$exec"))."
        ps_ret=1
      fi
      rm "$tmp_usage_file"
    else
      log_error "Couldn't find executable file for step '$1' ($(basename "$exec"))."
      ps_ret=1
    fi
  elif [[ "$1" == "usage" ]]; then
    usage -f
  elif [[ $# -eq 0 ]] || [[ "$1" == 'help' ]]; then
    echo 'Please provide a topic you need help on.'
    echo "Available help topics:"
    echo "  steps profiles usage ${LIFECYCLE_ALL_STEPS[*]}"
  else
    echo "Sorry, this script cannot provide help on an unknown topic."
    echo "Run \`$0 help\` to see all available topics."
    ps_ret=1
  fi
  return $ps_ret
}

#------------------------------------------------------------------------------
# Delegates each step to a separate script.
# This method takes its input from two variables that will be manipulated
# accordingly to the current step executed. It will first search for the function
# identified by BUILD_MNGER_STEP_FNC_PATT, execute it if it exists or for
# a file in the same directory (BUILD_MANAGER_DIR) identified by
# BUILD_MNGER_STEP_FILE_PATT and run it. If the step doesn't have a method
# or a file declared for it, this method will return with the exit status 126.
# The sequence of steps is interrupted if one returns with an error, unless
# the continue on error option is specified.
#------------------------------------------------------------------------------
launch_steps() {
  local step exec exec_path ps_ret step_args
  for step in "${LIFECYCLE_STEPS[@]}"; do
    # Name of executable according to config
    exec="${BUILD_MNGER_STEP_FILE_PATT//'%STEP%'/$step}"
    # Absolute path to executable
    exec_path="$BUILD_MANAGER_DIR/$exec"
    # Name of the method to run
    fnc="${BUILD_MNGER_STEP_FNC_PATT//'%STEP%'/$step}"
    # First check if function exists
    if check_function_exists "$fnc"; then
      $fnc
      ps_ret=$?
    # Check if file exists and is executable
    elif [[ -x "$exec_path" ]]; then
      $exec_path
      ps_ret=$?
    # If executable exists but isn't executable
    elif [[ -f "$exec_path" ]] && [[ ! -x "$exec_path" ]]; then
      log_error "File '$exec' is available but cannot be run for step '$step'."
      ps_ret=126
    else
      # End in error if couldn't find any
      log_error "No method ($fnc()) or file ($exec) set to launch step '$step'."
      ps_ret=2
    fi
    # Break the execution if continue on error is not set
    if [[ $ps_ret -ne 0 ]] && [[ $O_CONTINUE_ON_ERROR -eq 1 ]]; then
      break
    fi
  done
  return $ps_ret
}

#------------------------------------------------------------------------------
# Prepares steps for the lifecycle, setting LIFECYCLE_STEPS variable.
# Args:
#   $*    Steps/profiles names.
#------------------------------------------------------------------------------
prepare_steps() {
  local ps_ret=0
  local arg
  # Profile with add/remove steps
  if [[ $O_STEPS_LIST -eq 1 ]]; then
    lifecycle_manage_steps --log "log_error (%FUNCNAME%)" "$@"
    ps_ret=$?
  else
    # Simple step list, take all into account if valid step
    _steps=()
    for arg; do
      # Filter to check if any parameter is valid
      if ! in_array "$arg" "${LIFECYCLE_ALL_STEPS[@]}"; then
        log_error "Unknown step/profile '"$arg"'"
        ps_ret=1
      else
        _steps+=("$arg")
      fi
    done
    [[ $ps_ret -eq 0 ]] && LIFECYCLE_STEPS=("${_steps[@]}")
  fi
  return $ps_ret
}

#==============================================================================
# MAIN
#==============================================================================

# Options check
while : ; do
  case "$1" in
   -c|--config) CONFIG_FILE="$2"; shift;;
   --continue-on-error) O_CONTINUE_ON_ERROR=0;;
   -b|--branch) REPO_BRANCH="$2"; shift;;
     -h|--help) usage -f; exit 0;;
        --list) O_STEPS_LIST=0;;
  -v|--version) SOFTWARE_VERSION="$2"; shift;;
-w|--workspace) BUILD_MANAGER_WORKSPACE="$2"; shift;;
       *) break;;
  esac
  shift
done

# Args checks
if [[ $# -eq 0 ]]; then
  log_error 'Wrong number of arguments.'
  usage
  exit 1
fi

# Run help
if [[ "$1" == 'help' ]]; then
  help "${@:2}"
  exit $?
fi

# Following section can be exported to a separate file that can be sourced by all
# steps files.
#---
# Define and export variables
[[ -z "$CONFIG_FILE" ]] && CONFIG_FILE="$(readlink -f "$(dirname "$0")")/build_manager.cfg"
# Set workspace from config file if not provided through command line
[[ -z "$BUILD_MANAGER_WORKSPACE" ]] && cfg_load_file_to_vars \
    --log 'log_warn [%FUNCNAME%]' \
    "$CONFIG_FILE" 'workspace=BUILD_MANAGER_WORKSPACE'
# If workspace still empty, set default which is this script's parent directory
[[ -z "$BUILD_MANAGER_WORKSPACE" ]] && BUILD_MANAGER_WORKSPACE="$(dirname "$0")/.."
# Absolutify the path
BUILD_MANAGER_WORKSPACE="$(readlink -f "$BUILD_MANAGER_WORKSPACE")"
#---

# Process steps/profiles
prepare_steps "$@" || exit 1
launch_steps
