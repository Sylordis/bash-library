#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/check_dependencies.sh"

# Auto launch function
test_checkDependencies() {
  test_and_assert --fnc "check_dependencies" --with-errors +psr'|' "$@"
}

# Single
test_checkDependencies '|1' foo
foo() { :; }
test_checkDependencies '|0' foo
unset -f foo
test_checkDependencies '|1' foo
# Multiple
test_checkDependencies '|1' foo bar
foo() { :; }
bar() { :; }
test_checkDependencies '|0' foo bar
unset -f foo
test_checkDependencies '|1' foo bar
unset -f bar
# Warning messages
test_checkDependencies 'ERROR: cannot find dependency 'SHAKA' on the system.|1' -w 'SHAKA'
test_checkDependencies "ERROR: cannot find dependency 'FOO' on the system.
ERROR: cannot find dependency 'BAR' on the system.|1" -w FOO BAR
test_checkDependencies 'ERROR: not found CARROT|1' -w='ERROR: not found __BIN__' 'CARROT'
test_checkDependencies "ERROR: not found CARROT
ERROR: not found TOMATO|1" -w='ERROR: not found __BIN__' CARROT TOMATO
