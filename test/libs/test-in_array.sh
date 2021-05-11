#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/in_array.sh"

# Auto launch function
test_inArray() {
  test_and_assert --fnc "in_array" -psr -mb "'$2' is in array? " "$@"
}

a1=(a b c d e f)
a2=(a b c d f)
a3=()
a4=(a "*" '$' "&")
a5=(y Y n N)
echo "array 1: {${a1[*]}}"
test_inArray 0 "a" "${a1[@]}"
test_inArray 1 "g" "${a1[@]}"
test_inArray 1 "" "${a1[@]}"
test_inArray 1 "*" "${a1[@]}"
test_inArray 1 "$" "${a1[@]}"
echo "array 2: {${a2[*]}}"
test_inArray 1 "e" "${a2[@]}"
test_inArray 0 "f" "${a2[@]}"
echo "array 3: {${a3[*]}}"
test_inArray 1 "s" "${a3[@]}"
test_inArray 1 "" "${a3[@]}"
echo "array 4: {${a4[*]}}"
test_inArray 1 "" "${a4[@]}"
test_inArray 0 "*" "${a4[@]}"
test_inArray 0 "$" "${a4[@]}"
test_inArray 1 "ab" "${a4[@]}"
echo "array 5: {${a5[*]}}"
test_inArray 0 "y" "${a5[@]}"
test_inArray 0 "Y" "${a5[@]}"
test_inArray 0 "n" "${a5[@]}"
test_inArray 0 "N" "${a5[@]}"
test_inArray 1 "h" "${a5[@]}"
