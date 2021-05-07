#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/dec2hex.sh"

test_dec2hex() {
  test_and_assert --fnc "dec2hex" -mb "(${*:2})16: " "$@"
}

test_dec2hex "" ""
test_dec2hex "0" "0"
test_dec2hex "F" "15"
test_dec2hex "261" "609"
test_dec2hex "FF" "255"
test_dec2hex "FFFFFF" "16777215"
