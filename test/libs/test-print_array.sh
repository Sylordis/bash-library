#! /bin/bash

# Helpers
source "$SH_PATH_UTILS/testing_framework.sh"

# Source
source "$SH_PATH_LIB/print_array.sh"

# Test
test_printArray() {
  test_and_assert --fnc print_array "$@"
}

a1=(a b c d)
a2=()
a3=("?" "*" "#" "$" "a b")
test_printArray "a, b, c, d" "${a1[@]}"
test_printArray "" "${a2[@]}"
test_printArray "?, *, #, $, a b" "${a3[@]}"
