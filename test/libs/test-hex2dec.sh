#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/hex2dec.sh"

test_hex2dec() {
  test_and_assert --fnc hex2dec -mb "($*)16: " "$@"
}

test_hex2dec "" ""
test_hex2dec "0" "0"
test_hex2dec "15" "F"
test_hex2dec "609" "261"
test_hex2dec "255" "FF"
test_hex2dec "16777215" "FFFFFF"
