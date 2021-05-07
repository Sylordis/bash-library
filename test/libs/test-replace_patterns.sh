#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIBS/replace_patterns.sh"

test_replace_patterns() {
  test_and_assert --fnc replace_patterns -Anl "$@"
}

test_replace_patterns '' ''
test_replace_patterns 'Hello world' 'Hello world'
test_replace_patterns 'Test __TEST_ __test__ _TEST__ _TEST_' 'Test __TEST_ __test__ _TEST__ _TEST_'
test_replace_patterns 'Hello ' 'Hello __WORLD__'

NAME=Hallgrim
test_replace_patterns "I'm $NAME from " "I'm __NAME__ from __PLACE__"

NAME=Orange
ADJ=shallow
readonly answer="$NAME is but a $ADJ for $NAME"
readonly sentence="__NAME__ is but a __ADJ__ for __NAME__"
test_replace_patterns "$answer" "$sentence"

# Tests option variable prefix -p
PV_NAME=Cherry
ADJ=Sweet
test_replace_patterns "Cherry is but a  for Cherry" -p 'PV_' "$sentence"
