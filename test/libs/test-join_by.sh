#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/join_by.sh"

# Auto launch function
test_joinBy() {
  test_and_assert --fnc join_by "$@"
}

a1=(a b c d e)
a2=("a b" c d e)
a3=(a "*" '$' "&")

test_joinBy ""
test_joinBy "" ","
test_joinBy "abcde" "" "${a1[@]}"
test_joinBy "a,b,c,d,e" "," "${a1[@]}"
test_joinBy "a)(b)(c)(d)(e" ")(" "${a1[@]}"
test_joinBy "a\nb\nc\nd\ne" "\n" "${a1[@]}"

test_joinBy "a b|c|d|e" "|" "${a2[@]}"
test_joinBy "a b? c? d? e" "? " "${a2[@]}"

test_joinBy "a , * , $ , &" " , " "${a3[@]}"
test_joinBy "# , # , #" " , " "#" "#" "#"
test_joinBy "%/%/%" "/" "%" "%" "%"
