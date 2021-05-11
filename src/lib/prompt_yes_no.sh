#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Prompts a yes/no question until a correct choice has been made by the user.
# This method and its outputs will be printed on /dev/tty, meaning they are
# not redirectable.
# Params:
#   $1    <prompt-msg> Prompt message
#  [$2]   [failure] Specific failure message (overrides the default message)
#  [$3]   [failure-patt] Pattern in the failure message for the user's answer's
#         placeholder
# Returns:
#   0/true if user answers yes, 1/false if he answers no
#------------------------------------------------------------------------------
prompt_yes_no() {
  local answer=""
  local exit_status=1
  # While the answer has not been given
  while : ; do
    # Pop the question
    read -p "$1 " answer
    # Filter the answer and stop while loop if acceptable answer
    case "$answer" in
      Y|y|N|n) break;;
    esac
    # Failure to answer as expected
    if [[ $# -gt 1 ]]; then
      # Set message, /dev/tty prevents from being printed in logs
      echo "${2//$3/$answer}" > /dev/tty
    else
      # Default message
      echo "'$answer' is not a correct answer." > /dev/tty
    fi
  done
  case "$answer" in
    Y|y) exit_status=0;;
  esac
  return $exit_status
}
