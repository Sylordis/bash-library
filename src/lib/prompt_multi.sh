#! /usr/bin/env bash

# Includes
source "$SH_PATH_LIB/join_by.sh"

#------------------------------------------------------------------------------
# Prompts a question with multiple choices and returns once a choice has been
# made or if the user cancels.
# This function and its outputs will not be printed.
# Params:
#   $*    <choices..> Choices, multiple possible answers
# Options:
#  -ap <V>  Pattern in the failure message for the user's answer's placeholder
#  -fm <V>  Specificies a failure message
#  -hm <V>  Specifies a header message
#  -mc[=V]  Specifies a multi-choice, and possible separator(s) for answering
#             (default=comma)
#  -nc      Forces the user to choose (no cancel)
#   -q <V>  Specifies a prompt message for the question
# Returns:
#   The indexes of the answers, or the cancel option if the user cancelled or
#   if the array was empty.
#   In case of multiple answers possible (-m), the indexes will be returned
#   with the first separator specified or the default comma.
#------------------------------------------------------------------------------
prompt_multi() {
  local answer_pattern="__ANSWER__"
  local text_pattern="__TEXT__"
  local FALSE=1
  local TRUE=0
  # Initialization
  local cancel_option="C"
  local failure_message="<$answer_pattern> is not a correct answer."
  local force=$FALSE
  local header_msg="Here are the available answers:"
  local multi_choice=$FALSE
  local multi_separator=""
  local prompt_msg="Please enter your choice(s):"
  local choice_line="${answer_pattern}) $text_pattern"
  # Others
  local result answer
  # Option parsing
  while : ; do
    case "$1" in
     -ap) shift; answer_pattern="$1";;
     -fm) shift; failure_message="$1";;
     -hm) shift; header_msg="$1";;
    -mc*) multi_choice=$TRUE
          if [[ "$1" == -mc=* ]]; then
            if [[ "$1" == "-mc=" ]]; then
              echo "Empty separator not allowed."
              exit 1
            fi
            multi_separator="${1#-mc=}"
          else
            multi_separator=","
          fi;;
     -nc) force=$TRUE;;
      -q) shift; prompt_msg="$1";;
       *) break;;
    esac
    shift
  done
  # Arg check, if none, return cancel
  [[ $# -eq 0 ]] && result="$cancel_option"
  if [[ -z "$result" ]]; then
    # Echo the header message
    local msg="$header_msg"
    if [[ $multi_choice -eq $TRUE ]]; then
      msg="$msg (multi-choice)"
    fi
    echo "$msg" > /dev/tty
    # Echo the choices
    local count=1
    local choice
    for choice in "$@"; do
      echo "$choice_line" | sed -re "s/$answer_pattern/$count/g" -e "s/$text_pattern/$choice/g" > /dev/tty
      ((count++))
    done
    # Echo cancel choice
    if [[ $force -eq $FALSE ]]; then
      echo "$choice_line" | sed -re "s/$answer_pattern/$cancel_option/g" -e "s/$text_pattern/Cancel/g" > /dev/tty
    fi
    while :; do
      # Pop the question
      #shellcheck disable=SC2162 `-r` screwes up everything
      read -p "$prompt_msg" answer
      # Check if total answer is correct
      # Cut answer according to separator
      local split_answer answer_part
      IFS="$multi_separator" read -r -a "split_answer" <<< "$answer"
      wrong_answers=()
      # Check every answer
      for answer_part in "${split_answer[@]}"; do
        # Check if answer is cancel
        if [[ "$answer_part" == "$cancel_option" && $force -eq $FALSE ]]; then
          wrong_answers=()
          answer="$cancel_option"
          break
        elif [[ -n "${answer_part//[0-9]/}" || "$answer_part" -gt $# ]]; then
            wrong_answers=("${wrong_answers[@]}" "$answer_part")
        fi
        # Wrong answer: contains something else than a number or not existing
      done
      if [[ ${#wrong_answers} -eq 0 ]]; then
        result="$answer"
        break
      else
        echo "$failure_message" | sed -re "s/$answer_pattern/$(join_by ", " "${wrong_answers[@]}")/g"
      fi
    done
  fi
  # Return answer
  echo "$result"
  # Erase footsteps
  unset wrong_answers
}
