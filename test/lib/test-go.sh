#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/go.sh"

test_go() {
  local currpwd expected result
  currpwd="$(pwd)"
  expected="$1"
  shift
  result=$(go "$@" 2>&1; [[ "$(pwd)" != "$currpwd" ]] && pwd)
  assert "$expected" "$result"
  cd "$currpwd"
}

working_directory_create test1 test1/folder1 test1/folder2 test2

GO_DYN_PATH_TT="echo '$TEST_WORKING_DIR/test1/folder2'"
GO_DYN_PATH_TESTY="echo '/somewhere'"

TEST1_HOME="$TEST_WORKING_DIR/test1"

test_go $'ERROR[go]: Nowhere to go sir!\nUsage: go <location> [suffixes..]'
test_go "$TEST1_HOME" TEST1
test_go "$TEST1_HOME" test1
test_go "$TEST1_HOME/folder1" test1 folder1
test_go "$(eval "$GO_DYN_PATH_TT")" tt
test_go "ERROR[go]: Location 'idontexist' not set nor valid." idontexist
test_go "ERROR[go]: Location 'IDONTEXIST' not set nor valid." IDONTEXIST
test_go "ERROR[go]: Location '/somewhere' does not exist." testy

working_directory_delete
