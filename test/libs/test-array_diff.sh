#! /bin/bash

# Helpers
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/array_diff.sh"
source "$SH_PATH_LIB/print_array.sh"

test_arrayDiff() {
  local expected="$1"
  shift
  array_diff "$@"
  assert "$expected" "$(print_array $(eval echo "\${$3[@]}"))"
}

a1=(a b c d)
a2=(a b f g)
a3=(e f g)
a4=()
a5=("a b" c)
result=()

d12=(c d)
test_arrayDiff "$(print_array "${d12[@]}")" "a1" "a2" "result"
d21=(f g)
test_arrayDiff "$(print_array "${d21[@]}")" "a2" "a1" "result"
d23=(a b)
test_arrayDiff "$(print_array "${d23[@]}")" "a2" "a3" "result"
d32=(e)
test_arrayDiff "$(print_array "${d32[@]}")" "a3" "a2" "result"
d31=(e f g)
test_arrayDiff "$(print_array "${d31[@]}")" "a3" "a1" "result"
d13=(a b c d)
test_arrayDiff "$(print_array "${d13[@]}")" "a1" "a3" "result"
test_arrayDiff "$(print_array "${a1[@]}")" "a1" "a4" "result_a4"
test_arrayDiff "$(print_array "${a4[@]}")" "a4" "a1" "result"

d51=("a b")
array_diff "a5" "a1" "result_maybe"
assert "$(print_array "${d51[@]}")" "$(print_array "${result_maybe[@]}")"

s1=("?" "*" "#" "$")
s2=("*" "/")
ds=("?" "#" "$")
test_arrayDiff "$(print_array "${ds[@]}")" "s1" "s2" "result_special"