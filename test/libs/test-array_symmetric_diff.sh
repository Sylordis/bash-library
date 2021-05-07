#! /bin/bash

# Helpers
source $SH_PATH_UTILS/testing_framework.sh

# Sources
source $SH_PATH_LIB/array_symmetric_diff.sh
source $SH_PATH_LIB/print_array.sh

test_arraySimDiff() {
  local expected="$1"
  shift
  local -n result_var="$3"
  array_symmetric_diff "$@"
  assert "$expected" "$(print_array "${result_var[@]}")"
}

a1=(a b c d)
a2=(a b f g)
a3=(e f g)
a4=()
a5=("a b" c)
result=()

d12=(c d f g)
test_arraySimDiff "$(print_array "${d12[@]}")" "a1" "a2" "result"
test_arraySimDiff "$(print_array "${d12[@]}")" "a2" "a1" "result"

d23=(a b e)
test_arraySimDiff "$(print_array "${d23[@]}")" "a2" "a3" "result"
test_arraySimDiff "$(print_array "${d23[@]}")" "a3" "a2" "result"

d31=(a b c d e f g)
test_arraySimDiff "$(print_array "${d31[@]}")" "a3" "a1" "result"
test_arraySimDiff "$(print_array "${d31[@]}")" "a1" "a3" "result"

test_arraySimDiff "$(print_array "${a1[@]}")" "a1" "a4" "result"

d35=("a b" c e f g)
test_arraySimDiff "$(print_array "${d35[@]}")" "a3" "a5" "result_maybe"
