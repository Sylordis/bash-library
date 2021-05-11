#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/to_lower.sh"

# Auto launch function
test_toLower() {
  test_and_assert --fnc to_lower "$@"
}

test_toLower ""
test_toLower "," ","

test_toLower "je suis un petit galopin" "Je suis un Petit Galopin"
test_toLower "testy" "TESTY"
test_toLower "testy" "testy"

test_toLower "a b c" "A" "b" "C"

test_toLower "*?" "*?"
