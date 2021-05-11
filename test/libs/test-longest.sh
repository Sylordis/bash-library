#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/longest.sh"

# Auto launch function
test_longest() {
  test_and_assert --fnc longest "$@"
}

a1=()
a2=(a 4 7 '' 3)
a3=(1 2 -1 abade)
a4=(a b c ab c de f ghi j k l mno p q rst)
echo "array 1: {${a1[*]}}"
test_longest '' "${a1[@]}"
test_longest 0 -s "${a1[@]}"
test_longest -1 -i "${a1[@]}"
echo "array 2: {${a2[*]}}"
test_longest a "${a2[@]}"
test_longest 1 -s "${a2[@]}"
test_longest 0 -i "${a2[@]}"
echo "array 3: {${a3[*]}}"
test_longest abade "${a3[@]}"
test_longest 5 -s "${a3[@]}"
test_longest 3 -i "${a3[@]}"
test_longest 5 -i -s "${a3[@]}"
test_longest 3 -s -i "${a3[@]}"
echo "array 4: {${a4[*]}}"
test_longest ghi "${a4[@]}"
test_longest 3 -s "${a4[@]}"
test_longest 7 -i "${a4[@]}"
