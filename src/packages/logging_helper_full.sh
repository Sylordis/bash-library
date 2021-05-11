#! /usr/bin/env bash

#==============================================================================
# This file can be sourced or included as is in a bash script.
# Logging helper is quite a pack, but logging is ensured to be a lot simpler
# when used.
# Only those main functions are to be used in usual code:
#   - log
#   - log_debug [-u]
#   - log_info
#   - log_error
#   - log_warn
#   - logger_configure
# The most critical method is of course the configuration, which takes only
# options to be set, see its documentation for more information.
#==============================================================================

#------------------------------------------------------------------------------
# in_array()
# Checks if a value is contained in an array.
# Params:
#   $1    Needle - the value to search for
#   $*    Haystack - all the values to search in
#           Don't forget to surround this argument by quotes to prevent bash
#           expansion of values (especially while using star-character.)
# Returns:
#   0/true if the value is in the array, 1/false otherwise
#------------------------------------------------------------------------------
in_array() {
  # Loop through the haystack
  local v
  for v in "${@:2}"; do
    # Value found, return true
    [[ "$v" == "$1" ]] && return 0
  done
  # Value not found, return false
  return 1
}

#------------------------------------------------------------------------------
# join_by()
# Joins all the elements given as argument with one expression.
# Params:
#   $1    Joining string
#   $*    Each element to join
# Returns:
#   All the elements joined.
#------------------------------------------------------------------------------
join_by() {
  local d="$1";
  shift
  echo -n "$1"
  shift
  printf "%s" "${@/#/$d}"
  echo
}

#------------------------------------------------------------------------------
# strip_color_tags()
# Strips all color tags from a text.
# Params:
#   $*    Text to strip
# Returns:
#   The text without any color tags.
#------------------------------------------------------------------------------
strip_color_tags() {
  echo -e "$@" | sed -r "s:\x1B\[[0-9;]*[mK]::g"
}

#------------------------------------------------------------------------------
# to_upper()
# Changes all characters in a string to uppercase.
# Apply any color tags after applying this method.
# Params:
#   $*    Any string
# Returns:
#   The uppercased string.
#------------------------------------------------------------------------------
to_upper() {
  echo "$@" | awk '{print toupper($0)}'
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PACKAGE LOGGER_HELPER
# Shared requirements: none.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Helper global variables

# Log file if has to output to one
LOGGER_LOG_FILE=""

LOGGER_LVL_NAME_DEBUG="DEBUG"
LOGGER_LVL_NAME_INFO="INFO"
LOGGER_LVL_NAME_ERROR="ERROR"
LOGGER_LVL_NAME_WARNING="WARN"
LOGGER_LVL_NUMBER_DEBUG="0"
LOGGER_LVL_NUMBER_INFO="100"
LOGGER_LVL_NUMBER_ERROR="999"
LOGGER_LVL_NUMBER_WARNING="500"
# Log levels, from most important to less important
LOGGER_LEVELS=("ERROR" "WARN" "INFO" "DEBUG")
# Current log level set
LOGGER_LEVEL="INFO"

# Logging file system saving methods, does not need to be set if no log file set
#   - APPEND    appends to the given log file (default)
#   - OVERWRITE overwrites given log file
#   - SAVE      saves given log file if exists and create a new file
LOGGER_FILE_SAVING_METHODS=("APPEND" "OVERWRITE" "SAVE")
LOGGER_FILE_SAVING_METHOD="${LOGGER_FILE_METHODS[0]}"
# Logging output type, does not need to be set if there's no log file set
#   - BOTH      outputs to standard streams and to a log file (default)
#   - FILE_ONLY outputs only to file
LOGGER_OUTPUT_TYPES=("BOTH" "FILE_ONLY")
LOGGER_OUTPUT_TYPE="${LOGGER_OUTPUT_TYPES[0]}"

#==============================================================================
# HELPER BASIC METHODS
# Those only should be used
#==============================================================================

#------------------------------------------------------------------------------
# logging_helper.log()
# Logs a message according to current configuration.
# Params:
#   $*    Message to log
# Options:
#   -nf     Prevents any logging to the log file.
#   -l <L>  Outputs a log with given level L. This is affected by the current
#           log display level set.
#   -s <S>  Uses the given stream redirection.
#------------------------------------------------------------------------------
log() {
  local level stream msg no_file
  no_file=1
  # Option parsing
  while : ; do
    case "$1" in
     -nf) no_file=0;;
      -l) level="$2"; shift;;
      -s) stream="$2"; shift;;
       *) break;;
    esac
    shift
  done
  msg="$*"
  if [[ -n "$level" ]]; then
    local _given_level _global_level
    _given_level="$(eval "echo \"\$LOGGER_LVL_NUMBER_$level\"")"
    _global_level="$(eval "echo \"\$LOGGER_LVL_NUMBER_$LOGGER_LEVEL\"")"
    # Exit if level should not be printed
    if [[ "$_given_level" -lt "$_global_level" ]]; then
      return 0
    fi
    # Append level to message
    msg="[$(printf "%-5s" "$level")] $msg"
  fi
  # Log file outputing
  if [[ -n "$LOGGER_LOG_FILE" ]] && [[ $no_file -eq 1 ]]; then
    strip_color_tags "$msg" >> "$LOGGER_LOG_FILE"
  fi
  # Terminal message outputing
  if [[ -z "$LOGGER_LOG_FILE" ]] || [[ "$LOGGER_OUTPUT_TYPE" != "${LOGGER_OUTPUT_TYPES[1]}" ]]; then
    local cmd
    cmd="echo -e"
    cmd="$cmd \"$msg\""
    [[ -n "$stream" ]] && cmd="$cmd $stream"
    eval "$cmd"
  fi
}

#------------------------------------------------------------------------------
# logging_helper.log_debug()
# Logs a message with DEBUG level.
# Options:
#   -u    makes the output uncatchable.
#------------------------------------------------------------------------------
log_debug() {
  if [[ "$1" == "-u" ]]; then
    shift
    log -l "$LOGGER_LVL_NAME_DEBUG" -s "> /dev/tty" "$@"
  else
    log -l "$LOGGER_LVL_NAME_DEBUG" "$@"
  fi
}

#------------------------------------------------------------------------------
# logging_helper.log_error()
# Logs a message with ERROR level.
#------------------------------------------------------------------------------
log_error() {
  log -l "$LOGGER_LVL_NAME_ERROR" -s ">& 2" "$@"
}

#------------------------------------------------------------------------------
# logging_helper.log_info()
# Logs a message with INFO level.
#------------------------------------------------------------------------------
log_info() {
  log -l "$LOGGER_LVL_NAME_INFO" "$@"
}

#------------------------------------------------------------------------------
# logging_helper.log_warn()
# Logs a message with WARN level.
#------------------------------------------------------------------------------
log_warn() {
  log -l "$LOGGER_LVL_NAME_WARNING" "$@"
}

#------------------------------------------------------------------------------
# logging_helper.logger_configure()
# Configures the logging helper with a set of parameters.
# Each parameter will warn if their value is not correct and if any happens,
# this method will return an exit-status of 1.
# Params: none.
# Options:
#   --file=F | -f F   Sets a log file.
#   --level=L| -l L   Sets a log output level. Every leveled output under this
#                     level will not be printed.
#                         @see LOGGER_LEVELS
#   --save=S | -s S   Sets behaviour if log file already exists.
#                         @see LOGGER_FILE_SAVING_METHODS
#   --type=T | -t T   Sets the output type.
#                         @see LOGGER_OUTPUT_TYPES
# Return:
#   0/true if configuration was successful, 1/false if at least one error
#   happened.
#------------------------------------------------------------------------------
logger_configure() {
  # Parse all arguments
  local estatus ereturn fileset
  ereturn=0
  fileset=1
  while [[ $# -gt 0 ]]; do
    estatus=0
    case "$1" in
        --file=*) _logger_set_file "${1##--file=}"; fileset=0;;
              -f) _logger_set_file "$2"
                  shift
                  fileset=0
                  ;;
       --level=*) _logger_set_log_level "${1##--level=}";;
              -l) _logger_set_log_level "$2"; shift;;
        --save=*) _logger_set_saving_method "${1##--save=}"; fileset=0;;
              -s) _logger_set_saving_method "$2"; shift; fileset=0;;
        --type=*) _logger_set_output_type "${1##--type=}";;
              -t) _logger_set_output_type "$2"; shift;;
               *) echo "ERROR[$FUNCNAME]: unknown setting '$1'." >& 2; estatus=1;;
    esac
    # Check if error happened and not already set
    [[ $estatus -eq 0 ]] && estatus=$?
    if [[ $estatus -ne 0 ]]; then
      ereturn=$estatus
    fi
    shift
  done
  [[ $fileset -eq 0 ]] && _logger_manage_file
  return $ereturn
}

#==============================================================================
# HELPER SPECIFIC METHODS
# Those methods should be used with care.
#==============================================================================

#------------------------------------------------------------------------------
# logging_helper._logger_set_file()
# Sets a log file for the logger.
# Params:
#   $1    Path to a file
#------------------------------------------------------------------------------
_logger_set_file() {
  LOGGER_LOG_FILE="$1"
}

#------------------------------------------------------------------------------
# logging_helper._logger_set_log_level()
# Sets a log level filter for the logger.
# Params:
#   $1    Log level
#------------------------------------------------------------------------------
_logger_set_log_level() {
  _logger_check_set_config "$1" "LOGGER_LEVELS" "LOGGER_LEVEL" "Unknown log level '$1'"
}

#------------------------------------------------------------------------------
# logging_helper._logger_set_saving_method()
# Sets a log file saving method for the logger.
# Params:
#   $1    Saving method
#------------------------------------------------------------------------------
_logger_set_saving_method() {
  _logger_check_set_config "$1" "LOGGER_FILE_SAVING_METHODS" "LOGGER_FILE_SAVING_METHOD" "Unknown saving method '$1'"
}

#------------------------------------------------------------------------------
# logging_helper._logger_set_output_type()
# Sets a log output type for the logger.
# Params:
#   $1    Log output type
#------------------------------------------------------------------------------
_logger_set_output_type() {
  _logger_check_set_config "$1" "LOGGER_OUTPUT_TYPES" "LOGGER_OUTPUT_TYPE" "Unknown output type '$1'"
}

#------------------------------------------------------------------------------
# logging_helper._logger_check_set_config()
# Checks and sets a logger parameter according to a set of values.
# If the new value is not correct, will output possible values.
# Params:
#   $1    Parameter new value
#   $2    Name of the array containing all possible values
#   $3    Name of the variable
#   $4    Error message if the variable does not have a correct value
#         The list of possible values will be outputed.
#------------------------------------------------------------------------------
_logger_check_set_config() {
  local var ps_ret
  var="$(to_upper "$1")"
  local -n _possible_values="$2"
  # Check if variable has a correct new value
  if in_array "$var" "${_possible_values[@]}"; then
    # If yes, set the new variable
    local -n new_var="$3"
    new_var="$var"
    ps_ret=0
  else
    # If no, go error
    echo "ERROR[logger]: $4, possible values are [$(join_by ', ' "${_possible_values[@]}")]." >& 2
    ps_ret=1
  fi
  return $ps_ret
}

#------------------------------------------------------------------------------
# logging_helper._logger_manage_file()
# Manages the log file and saving methods according to configuration.
# Logger will make the script exit if an error happens.
#------------------------------------------------------------------------------
_logger_manage_file() {
  if [[ -n "$LOGGER_LOG_FILE" ]] && [[ ! -f "$LOGGER_LOG_FILE" ]]; then
    if ! touch "$LOGGER_LOG_FILE" 2> /dev/null; then
      echo "ERROR[logger]: Cannot create new log file '$LOGGER_LOG_FILE'." >& 2
      exit 1
    fi
  else
    case "$LOGGER_FILE_SAVING_METHOD" in
         APPEND) ;; #do_nothing
      OVERWRITE) echo -n "" > "$LOGGER_LOG_FILE";;
           SAVE) if [[ -f "$LOGGER_LOG_FILE" ]]; then
                   local dir name ext newname
                   dir="$(dirname "$LOGGER_LOG_FILE")"
                   name="$(basename "$LOGGER_LOG_FILE")"
                   [[ "$name" == *.* ]] && ext="${name#*.}"
                   name="${name%%.*}"
                   newname="${name}_$(date +%Y%m%d-%H%M%S)"
                   [[ -n "$ext" ]] && newname="$newname.$ext"
                   [[ -f "$newname" ]] && newname="$newname~$(find "$dir" -maxdepth 1 -name "$newname*" | wc -l)"
                   mv "$LOGGER_LOG_FILE" "$dir/$newname" || exit 1
                 fi
                 touch "$LOGGER_LOG_FILE" || exit 1
                 ;;
    esac
  fi
}
