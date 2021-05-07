#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Includes
source "$SH_PATH_LIBS/array_equals.sh"

test_arrayEquals() {
  TEST_METHOD='array_equals'
  test_and_assert -psr "$@"
}

test_arrayEquals 0
test_arrayEquals 1 a
a=(a b c)
test_arrayEquals 1 a b
b=(a b d)
test_arrayEquals 1 a b
b=("${a[@]}")
test_arrayEquals 0 a b
a=()
b=()
test_arrayEquals 0 a b
