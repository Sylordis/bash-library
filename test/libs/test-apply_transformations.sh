#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"
source "$SH_PATH_LIB/to_lower.sh"

# Sources
source "$SH_PATH_LIB/apply_transformations.sh"

test_applyTransformations() {
  test_and_assert --fnc apply_transformations -Anl "$@"
}

remove_os() {
  tr -d 'o' <<< "$1"
}

test_applyTransformations "" ""
test_applyTransformations "testy" "testy"
test_applyTransformations "testy" "TESTY" "to_lower"
test_applyTransformations "i'm nt gd" "I'M NOT GOOD" "to_lower" "remove_os"
test_applyTransformations "Thank" "Thank" "foo"
