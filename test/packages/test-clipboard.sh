#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_PACKS/clipboard.sh"

# Auto launch function
test_clipboard() {
  local currpwd expected result
  expected="$*"
  result=$(clip_put "$@"; clip_get)
  assert "$expected" "$result"
}

test_clipboard " "
test_clipboard "hello"
test_clipboard "this" "is" "amazing!"
assert "this is amazing!" "$(clip_get)"
