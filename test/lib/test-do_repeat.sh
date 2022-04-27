#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Some tests variables
_script="$SH_PATH_LIB/do_repeat.sh"
_eval_line=$(grep -nE "eval .*@" "$_script" | cut -d ':' -f 1)
_cmd_not_found_msg="$(TEST_error CMD_NOT_FOUND "$_script" "$_eval_line" "blah")"

# Sources
source "$_script"

# Auto-launcher
test_doRepeat() {
  test_and_assert --fnc "do_repeat" -An --with-errors "$@"
}

foo() {
  echo "bar"
}

# Weird inputs
test_doRepeat "" 0 foo
test_doRepeat "" -1 foo
test_doRepeat "" a foo
test_doRepeat "" 2

test_doRepeat $'bar\nbar\nbar' 3 foo
test_doRepeat "$_cmd_not_found_msg
$_cmd_not_found_msg
$_cmd_not_found_msg
$_cmd_not_found_msg" 4 blah
test_doRepeat $'world\nworld' 2 echo "world"

unset _eval_line _script _cmd_not_found_msg
