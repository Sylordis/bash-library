#! /usr/bin/env bash

#==============================================================================
# Launches any process in the background.
# If a timer is set, program will kill itself at the end of the timer.
#==============================================================================

#------------------------------------------------------------------------------
# usage()
# Displays usage message.
#------------------------------------------------------------------------------
usage() {
  echo "usage: $0 [-t time] [-s src] <cmd..>"
  echo "  cmd      command to be fully executed"
  echo "  -v       verbose mode"
  echo "  -s src   file to be sourced first"
  echo "  -t time  time duration limit (overrides -w)"
  echo "  -w       wait for background process to finish"
}

line_begin="\e[33m=>\e[0m"

G_CURRENT_CMD_LINE="$0 $*"
# Options
O_SOURCE="" # TBSL
O_TIME_LIMIT="" # TBSL
O_WAIT=1
O_VERBOSE=1

# Read options
while : ; do
  case "$1" in
   -h|--help) usage; exit 0;;
   -s) O_SOURCE="$2"; shift;;
   -t) if grep -q '[^0-9.]' <<< "$2"; then
         echo "ERROR: Option -t must have a number as argument." >& 2
         usage
         exit 1
       else
         O_TIME_LIMIT="$2"
       fi
       shift;;
   -v) O_VERBOSE=0;;
   -w) O_WAIT=0;;
    *) break;;
  esac
  shift
done

# Argument check
if [[ $# -eq 0 ]]; then
  echo "ERROR: Wrong number of arguments." >& 2
  usage
  exit 1
fi

# Check if file has to be sourced first
if [[ -n "$O_SOURCE" ]]; then
  # Check if file exists can be sourced
  if [[ -x "$O_SOURCE" ]]; then
    if source "$O_SOURCE"; then
        if [[ $O_VERBOSE -eq 0 ]]; then
          echo -e "$line_begin $O_SOURCE sourced"
        fi
    else
      echo "ERROR: Sourcing was not successful, aborting." >& 2
      exit 1
    fi
  else
    echo "ERROR: File to source '$O_SOURCE' does not exist or is not sourceable." >& 2
    exit 1
  fi
fi

# Check if process can be launched
if [[ -n "$(type -t "$1")" ]]; then
  if [[ $O_VERBOSE -eq 0 ]]; then
    echo -e "$line_begin Executing: \e[94m$*\e[0m"
    echo -en "$line_begin Timer: "
    if [[ -n "$O_TIME_LIMIT" ]]; then
      echo "set to $O_TIME_LIMIT seconds"
    else
      echo "none, remember to kill the process yourself"
      echo -e "\e[2mpkill -f \"$G_CURRENT_CMD_LINE\"\e[0m"
    fi
  fi
  # Launch it
  "$@" &
  ps_pid=$!
  if [[ -n "$O_TIME_LIMIT" ]]; then
    sleep "$O_TIME_LIMIT"
    # Clean kill
    kill -9 $ps_pid
    if [[ $? -eq 0 ]]; then
      if [[ $O_VERBOSE -eq 0 ]]; then
        echo -e "\n$line_begin Process $ps_pid was killed with success."
      fi
    else
      echo -e "WARN: Process could not be killed." >& 2
    fi
  elif [[ "$O_WAIT" -eq 0 ]]; then
    wait "$ps_pid"
    if [[ $O_VERBOSE -eq 0 ]]; then
      echo -e "$line_begin Process $ps_pid has terminated, exiting."
    fi
  fi
else
  echo "ERROR: '$1' unlaunchable process." >& 2
  exit 1
fi
