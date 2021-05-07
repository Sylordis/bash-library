#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIBS/biggest_in_array.sh"

# Auto launch function
test_biggestInArray() {
  test_and_assert --fnc "biggest_in_array" "$@"
}

a1=(6 a 8 1 8 8 6 6 2 8)
a2=(-7 -10 -3 -5 "")
a3=()
a4=(a 4 7 abc 3)
a5=(1 2 -1 abade)
a6=(a ab c de f ghi j k l mno p q rst)
# a7=(-0 -3.5 4.2 4.3 8.0000001 8.0001)
echo "array 1: {${a1[*]}}"
test_biggestInArray 8 "${a1[@]}"
test_biggestInArray 8 -tl "${a1[@]}"
test_biggestInArray a -tlo "${a1[@]}"
test_biggestInArray a -tlo -tl "${a1[@]}"
test_biggestInArray a -tl -tlo "${a1[@]}"
echo "array 2: {${a2[*]}}"
test_biggestInArray -3 "${a2[@]}"
test_biggestInArray "" -tl "${a2[@]}"
test_biggestInArray "" -tlo "${a2[@]}"
echo "array 3: {${a3[*]}}"
test_biggestInArray 0 "${a3[@]}"
test_biggestInArray 0 -tl "${a3[@]}"
test_biggestInArray 0 -tlo "${a3[@]}"
echo "array 4: {${a4[*]}}"
test_biggestInArray 7 "${a4[@]}"
test_biggestInArray 7 -tl "${a4[@]}"
test_biggestInArray abc -tlo "${a4[@]}"
echo "array 5: {${a5[*]}}"
test_biggestInArray 2 "${a5[@]}"
test_biggestInArray abade -tl "${a5[@]}"
test_biggestInArray abade -tlo "${a5[@]}"
echo "array 6: {${a6[*]}}"
test_biggestInArray "" "${a6[@]}"
test_biggestInArray ghi -tl "${a6[@]}"
test_biggestInArray ghi -tlo "${a6[@]}"
# echo "array 7: {${a7[@]}}"
# test_biggestInArray 8.0001 "${a7[@]}"
# test_biggestInArray 8.0001 -tl "${a7[@]}"
# test_biggestInArray "" -tlo "${a7[@]}"
