#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIBS/count_in_array.sh"

# Auto launch function
test_countInArray() {
  test_and_assert --fnc "count_in_array" -mb "Counting '$2' " "$@"
}

a1=(6 10 8 1 8 8 6 6 2 8)
a2=(9 3 2 5 7 8 3 8 3 7)
a3=()
a4=(a "*" '$' "&")
a5=(y Y n N y a b c)
echo "array 1: {${a1[*]}}"
test_countInArray 3 6 "${a1[@]}"
test_countInArray 1 10 "${a1[@]}"
test_countInArray 0 "" "${a1[@]}"
test_countInArray 0 "*" "${a1[@]}"
test_countInArray 0 "$" "${a1[@]}"
echo "array 2: {${a2[*]}}"
test_countInArray 3 "3" "${a2[@]}"
test_countInArray 2 8 "${a2[@]}"
test_countInArray 0 "e" "${a2[@]}"
test_countInArray 0 "f" "${a2[@]}"
echo "array 3: {${a3[*]}}"
test_countInArray 0 "s" "${a3[@]}"
test_countInArray 0 "" "${a3[@]}"
echo "array 4: {${a4[*]}}"
test_countInArray 0 "" "${a4[@]}"
test_countInArray 1 "*" "${a4[@]}"
test_countInArray 1 "$" "${a4[@]}"
test_countInArray 0 "ab" "${a4[@]}"
echo "array 5: {${a5[*]}}"
test_countInArray 2 "y" "${a5[@]}"
test_countInArray 1 "Y" "${a5[@]}"
test_countInArray 1 "n" "${a5[@]}"
test_countInArray 1 "N" "${a5[@]}"
test_countInArray 0 "h" "${a5[@]}"
