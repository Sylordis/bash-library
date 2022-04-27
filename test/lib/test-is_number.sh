#! /usr/bin/env bash

# Helpers includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/is_number.sh"

test_isNumber() {
  test_and_assert --fnc 'is_number' -psr -mb "'$2' is a number? " "$@"
}

test_isNumber 0 -10
test_isNumber 0 5
test_isNumber 0 0
test_isNumber 0 -0
test_isNumber 0 10
test_isNumber 0 0.1
test_isNumber 1 5.
test_isNumber 1 .3
test_isNumber 1 a
test_isNumber 1 './*'
test_isNumber 1 "#"
