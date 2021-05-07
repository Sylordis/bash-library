#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIBS/check_function_exists.sh"

# Auto launch function
test_checkFunctionExists() {
  test_and_assert --fnc "check_function_exists" -psr "$@"
}

# Tests part

test_checkFunctionExists 1 "foo"
foo() {
  echo -n ""
}
test_checkFunctionExists 0 "foo"

unset -f foo
test_checkFunctionExists 1 "foo"
