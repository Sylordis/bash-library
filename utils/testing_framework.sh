#! /usr/bin/env bash

# Inherit traps from all sources
set -o functrace

source "$SH_DEBUG"
source "$SH_PATH_UTILS/mocks.sh"
source "$SH_PATH_UTILS/working_directory.sh"

# Generic
TRUE=0
FALSE=1

# Tests results
FAILED_TESTS=0
PASSED_TESTS=0

# Trap for a normal exit
clean_exit() {
  TEST_print_test_results
  mocks_delete_all
  working_directory_delete
}

#------------------------------------------------------------------------------
# is_true()
# Checks whether or not a variable is set.
# Params:
#   $1    Variable to check against
# Returns:
#   0/true if set, 1/false otherwise
#------------------------------------------------------------------------------
is_true() {
  [[ "$1" -eq $TRUE ]]
}

#------------------------------------------------------------------------------
# TEST_error()
# Echoes specific error messages.
# IMPORTANT: This will not work with anything else than an en_GB set terminal as
#            error messages will be different acccording to language.
# Params:
#   $1    Error type
#  [$*]   Arguments (specific to each error)
#------------------------------------------------------------------------------
TEST_error() {
  local ret=""
  local err="$1"
  shift
  case "$err" in
    DIR_NOT_FOUND) ret="Directory $1 doesn't exist";;
    CMD_NOT_FOUND) ret="$1: line $2: $3: command not found"
  esac
  echo "$ret"
}

#------------------------------------------------------------------------------
# TEST_failed()
# Marks a test as failed.
#------------------------------------------------------------------------------
TEST_failed() {
  echo -e "\e[91mfailed\e[0m"
  ((FAILED_TESTS++))
}

#------------------------------------------------------------------------------
# TEST_passed()
# Marks a test as passed.
#------------------------------------------------------------------------------
TEST_passed() {
  echo -e "\e[92mpassed\e[0m"
  ((PASSED_TESTS++))
}

#------------------------------------------------------------------------------
# Default test function that tests provided method returns expected result.
# Method under test can either be provided through option -f or via the global
# variable TEST_METHOD.
# Params:
#   $1    Expected result
#   $*    Arguments for command
# Options:
#   -A<X>|-A <X>      Where X is an option for assert()
#   --exp-colours     Takes cares of colour comparisons in expected results
#   -f <F>|--_fnc <F>  Method under test that will be evaluated
#   --feed <feed>     Pipes the food to given method as text
#   -mb <msg>         Prints a message before the test
#   --out <output>|--output <output>
#                     Outputs given text as output (for methods that change variables).
#                     It will be echoed as unquoted string.
#   -psr              Only considers the process exit status
#   +psr<S>           Adds the process exit status at the end of the result,
#                     separated with <S> string
#   --with-errors     Captures the err stream in std
#
#------------------------------------------------------------------------------
test_and_assert() {
  local _fnc _ps_ret
  local o_assert_opts o_msg_prefix
  local o_ps_ret_sep o_feed o_output
  local o_exp_colours=1 o_ps_ret=1 o_collect_errors=1
  while : ; do
    case "$1" in
         -A) o_assert_opts="$2"; shift;;
        -A*) o_assert_opts="${1##-A}";;
  --exp-colours) o_exp_colours=0;;
     --feed) o_feed="$2"; shift;;
   -f|--fnc) _fnc="$2"; shift;;
        -mb) o_msg_prefix="$2"; shift;;
  --out|--output) o_output="$2"; shift;;
       -psr) o_ps_ret=0;;
      +psr*) o_ps_ret=0
             o_ps_ret_sep="${1##+psr}";;
   --with-errors) o_collect_errors=0;;
       *) break;;
    esac
    shift
  done
  # Set method to test if not set
  [[ -z "$_fnc" ]] && _fnc="$TEST_METHOD"
  # Check if there's something to test
  if [[ -z "$_fnc" ]]; then
    echo "ERROR[$FUNCNAME]: No function to test. Use -f, --_fnc or TEST_METHOD variable." >& 2
    return 1
  fi
  # Test
  local _expected="$1"
  [[ $o_exp_colours -eq 0 ]] && _expected="$(echo -e "$1")"
  shift
  local _result
  # Create result according to inputs
  if [[ -n $o_feed ]]; then
      if [[ $o_collect_errors -eq 0 ]]; then
        _result="$(printf "$o_feed" | $_fnc "$@" 2>& 1)"
      else
        _result="$(printf "$o_feed" | $_fnc "$@")"
      fi
  else
    if [[ $o_collect_errors -eq 0 ]]; then
      _result="$($_fnc "$@" 2>& 1)"
    else
      _result="$($_fnc "$@")"
    fi
  fi
  _ps_ret=$?
  # Replace output if needed
  [[ -n "$o_output" ]] && _result="$(eval "echo ${o_output//\\/}")"
  # Check if have to use process exit status
  if [[ $o_ps_ret -eq 0 ]] && [[ -z $o_ps_ret_sep ]]; then
    _result="$_ps_ret"
  elif [[ -n $o_ps_ret_sep ]]; then
    _result+="${o_ps_ret_sep}${_ps_ret}"
  fi
  # Message and assert
  [[ -n "$o_msg_prefix" ]] && echo -n "$o_msg_prefix"
  # Process assert_ops
  local i assert_opts
  for ((i=0;i<${#o_assert_opts};i++)); do
    assert_opts+=" -${o_assert_opts:$i:1}"
  done
  # Assert
  assert $assert_opts "$_expected" "$_result"
}

#------------------------------------------------------------------------------
# assert()
# Asserts a result according to the expectations, and maintain the statistics
# about the tests.
# Params:
#   $1    Expected result (use $'text' for new lines and special characters)
#   $2    Actual result
# Options:
#   -l    Displays the length of each result (and expected)
#   -n    Prints each print on a new line
#------------------------------------------------------------------------------
assert() {
  # Options setting
  local newline=$FALSE
  local show_length=$FALSE
  local o_ps_ret=1
  while : ; do
    case "$1" in
      -l) show_length=$TRUE;; # -l prints the length of the results
      -n) newline=$TRUE;;     # -n puts every text on a new line
       *) break;;
    esac
    shift
  done
  # If arguments lower than 2, exit
  if [[ $# -lt 2 ]]; then
    echo "ERROR[$FUNCNAME]: expected 2 arguments, got $#." >& 2
    TEST_failed
    return
  fi
  local _result _expected
  _result="$2"
  # Print results
  if grep -oqE "%%ERROR_[^%]+%%" <<< "$1"; then
    local error_type arguments
    error_type="$(echo "$1" | sed -re 's/^%%ERROR_([^%]+)%% .*$/\1/g')"
    arguments="$(echo "$1" | cut -d " " -f 2-)"
    _expected="$(eval "TEST_error $error_type $arguments")"
  else
    _expected="$1"
  fi
  echo -en "expected=[${_expected}]"
  is_true $show_length && echo -n " |${#_expected}|"
  is_true $newline && echo ""
  ! is_true $newline && echo -n ", "
  is_true $newline && echo -n "  "
  echo -en "result=[$_result]"
  is_true $show_length && echo -n " |${#_result}|"
  is_true $newline && echo ""
  ! is_true $newline && echo -n " "
  # Set state of test
  if [[ "$_expected" == "$_result" ]]; then
    TEST_passed
  else
    TEST_failed
  fi
}

#------------------------------------------------------------------------------
# TEST_print_test_results()
# Prints the test results according to passed or failed tests ran.
#------------------------------------------------------------------------------
TEST_print_test_results() {
  echo ""
  local ctests=$((FAILED_TESTS+PASSED_TESTS))
  echo -e "Out of $ctests tests: \e[92mPassed\e[0m $PASSED_TESTS / \e[91mFailed\e[0m $FAILED_TESTS"
  echo -n "Conclusion of the test: "
  if [[ $ctests -eq 0 ]]; then
    echo -e "\e[95mNo tests to pass :/\e[0m"
  elif [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "\e[92mPASSED =D\e[0m"
  else
    echo -e "\e[91mFAILED =(\e[0m"
  fi
}

# Enforce the print of the results, and prevents from having to use the method elsewhere
trap clean_exit EXIT
