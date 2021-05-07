#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIBS/margin.sh"

test_margin(){
  test_and_assert --fnc margin "$@"
}

test_margin ' '
test_margin ' ' 1
test_margin 'a' 1 a
test_margin '   ' 3
test_margin 'bbb' 3 b
test_margin 'babababa' 4 ba
test_margin '()()' 2 '()'
test_margin '  ' 2 ' '
test_margin 'f *f *' 2 'f *'

# Only second argument is taken
test_margin 'ff' 2 f ./*

# Special test, special characters do not work
test_margin '' 3 "\n"
