#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/to_upper.sh"
source "$SH_PATH_PACKS/function_extender.sh"

# Auto-launcher
test_functionExtender() {
  local expected_str="$1"
  local expected_ES="$2"
  shift 2
  local result
  result="$(eval "$@" 2>&1) $?"
  assert -n "$expected_str $expected_ES" "$result"
}

test_functionExtender_getExtensions() {
  local expected_str="$1"
  shift
  local result
  result="$(get_function_extensions "$@")"
  assert -n "$expected_str" "$result"
}

# Misc functions for test
myfunc() {
  echo "${@//[aA]/}"
}

result1="I'm the extension 'var'!"
result2="I'm the extension 'VAR'!"
result3="I'm a special snowflake!"
extension="var"
func_name="foo"

foo() {
 launch_function_extension "$FUNCNAME" "$extension" "$@"
 return $?
}
foo_bar() { echo "hello world"; }
foo_var() { echo "$result1"; }
foo_BAR() { echo "hello WORLD"; }
foo_VAR() { echo "$result2"; }
FOO_VAR() { echo "$result3"; }
bar() {
  launch_function_extension "foo?"
}


FNC_EXT_NAME_PATTERN="%BASE%_%EXT%"
test_functionExtender "$result1" 0 foo
test_functionExtender_getExtensions $'foo_bar\nfoo_var' foo

FNC_EXT_NAME_PATTERN="%BASE%_%EXT:to_upper%"
test_functionExtender "$result2" 0 foo
test_functionExtender_getExtensions $'foo_BAR\nfoo_VAR' foo

FNC_EXT_NAME_PATTERN="%BASE:to_upper:myfunc%_%EXT:to_upper%"
test_functionExtender "$result3" 0 foo
test_functionExtender_getExtensions $'FOO_VAR' foo

FNC_EXT_NAME_PATTERN="%BASE:to_upper%_%EXT:to_upper:myfunc%"
test_functionExtender "ERROR: Program not set for extension 'FOO_VR' of feature '$func_name'" 1 foo
test_functionExtender_getExtensions "" foo

test_functionExtender "ERROR: launch_function_extension, wrong number of arguments." 1 bar
