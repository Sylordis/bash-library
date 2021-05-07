#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/trim.sh"

test_trim() {
  test_and_assert --fnc trim -Anl "$@"
}

test_trim "test" " test"
test_trim "test" "test "
test_trim "test" " test "
test_trim "test test" " test test "
# Tabs
test_trim "test test" " test test		"
test_trim "test test test" " test " " test " " test "

test_trim " test " -f "  test  "

test_trim "test " -l " test "
test_trim " test" -t " test "
test_trim " test " -t -l " test "

test_trim "test" -r a "aaatestaaa"
test_trim "toast" -r a "aaatoastaaa"
test_trim " test " -r a " test "
test_trim "bsolute" -r a "absolute"
test_trim "absolute" -r a -t "absolute"
test_trim "test" -r " " " test "
test_trim " test " -r "samoa" " test "
test_trim "testsamo" -r "samoa" "samoasamoatestsamo"
test_trim "samoatestsamo" -r "samoa" -f "samoasamoatestsamo"
