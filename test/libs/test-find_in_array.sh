#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/find_in_array.sh"

# Auto launch function
test_findInArray() {
  test_and_assert --fnc find_in_array "$@"
}

a1=(6 a 8 1 6 2 8.0001 "my string" "*")
a2=()
echo "array 1: {${a1[*]}}"
test_findInArray 0 6 "${a1[@]}"
test_findInArray 1 a "${a1[@]}"
test_findInArray 6 8.0001 "${a1[@]}"
test_findInArray -1 ./* "${a1[@]}"
test_findInArray 8 "*" "${a1[@]}"
test_findInArray 7 "my string" "${a1[@]}"
echo "array 2: {${a2[*]}}"
test_findInArray -1 smth "${a2[@]}"
