#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"
source "$SH_PATH_LIB/print_array.sh"

# Sources
source "$SH_PATH_LIB/filter_array.sh"

# Formats the answer
answer() {
  local answer
  answer="$(print_array "${@:1:$#-1}")"
  echo "$answer|${@:$#}"
}

test_filterArray() {
  local expected result
  expected="$1"
  shift
  filter_array "$@"
  local op_res=$?
  local result="|1"
  if [[ $# -ge 2 ]]; then
    local -n _array="$2"
    result="$(answer "${_array[@]}" $op_res)"
  fi
  assert "$expected" "$result"
}

test_filterArray "$(answer 1)" a
test_filterArray "$(answer 1)" a b ""
arr=(a b c)
test_filterArray "$(answer "${arr[@]}" 0)" arr arr_b ""
test_filterArray "$(answer a b 0)" arr arr_c '[[ "%ARG%" != "c" ]]'
test_filterArray "$(answer 0)" arr arr_c '[[ -z "%ARG%" ]]'
