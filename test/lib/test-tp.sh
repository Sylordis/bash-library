#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/tp.sh"

test_tp() {
  local currpwd expected result
  currpwd="$(pwd)"
  expected="$1"
  shift
  result=$(tp "$@" 2>&1; [[ "$(pwd)" != "$currpwd" ]] && pwd)
  assert "$expected" "$result"
  cd "$currpwd"
}

working_directory_create test1 test1/folder1 test1/folder2 test2

TP_DYN_PATH_TT="echo '$TEST_WORKING_DIR/test1/folder2'"
TP_DYN_PATH_TESTY="echo '/somewhere'"

TEST1_HOME="$TEST_WORKING_DIR/test1"

test_tp $'ERROR[tp]: Nowhere to go sir!\nUsage: tp <location> [suffixes..]'
test_tp "$TEST1_HOME" TEST1
test_tp "$TEST1_HOME" test1
test_tp "$TEST1_HOME/folder1" test1 folder1
test_tp "$(eval "$TP_DYN_PATH_TT")" tt
test_tp "ERROR[tp]: Location 'idontexist' not set nor valid." idontexist
test_tp "ERROR[tp]: Location 'IDONTEXIST' not set nor valid." IDONTEXIST
test_tp "ERROR[tp]: Location '/somewhere' does not exist." testy

working_directory_delete
