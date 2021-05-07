#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIBS/to_upper.sh"

# Auto launch function
test_toUpper() {
  test_and_assert --fnc to_upper "$@"
}

test_toUpper ""
test_toUpper "," ","

test_toUpper "JE SUIS UN PETIT GALOPIN" "Je suis un Petit Galopin"
test_toUpper "TESTY" "TESTY"

test_toUpper "A B C" "A" "b" "C"

test_toUpper "*?" "*?"
