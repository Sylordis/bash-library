#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/replace_patterns.sh"

test_replace_patterns() {
  test_and_assert --fnc replace_patterns -Anl "$@"
}

test_replace_patterns '' ''
test_replace_patterns 'Hello world' 'Hello world'
test_replace_patterns 'Test __TEST_ __test__ _TEST__ _TEST_' 'Test __TEST_ __test__ _TEST__ _TEST_'
test_replace_patterns 'Hello ' 'Hello __WORLD__'

NAME=Hallgrim
test_replace_patterns "I'm $NAME from " "I'm __NAME__ from __PLACE__"
unset NAME

NAME=Orange
ADJ=shallow
readonly answer="$NAME is but a $ADJ for $NAME"
readonly sentence="__NAME__ is but a __ADJ__ for __NAME__"
test_replace_patterns "$answer" "$sentence"
unset NAME ADJ

# Tests option variable prefix -p
PV_NAME=Cherry
ADJ=Sweet
test_replace_patterns "Cherry is but a  for Cherry" -p 'PV_' "$sentence"
unset PV_NAME ADJ

# Tests option for pattern delimiters
readonly sentence2='%TREE% is %ADJ% and also gives __ADJ_2% %THING__'
TREE=Oak
ADJ=strong
ADJ_2=deep
THING=shadow
test_replace_patterns "Oak is strong and also gives __ADJ_2% %THING__" \
    -d '%' "$sentence2"
test_replace_patterns "%TREE% is %ADJ% and also gives __ADJ_2% shadow" \
    -db '%' "$sentence2"
test_replace_patterns "%TREE% is %ADJ% and also gives deep %THING__" \
    -de '%' "$sentence2"
unset TREE ADJ ADJ_2 THING

# Test option for prefix and pattern delimiters
TEST_TREE=Birch
TEST_ADJ=thin
TEST_ADJ_2=nice
TEST_THING=wood
test_replace_patterns "Birch is thin and also gives __ADJ_2% %THING__" \
    -d '%' -p 'TEST_' "$sentence2"
test_replace_patterns "%TREE% is %ADJ% and also gives __ADJ_2% wood" \
    -db '%' -p 'TEST_' "$sentence2"
test_replace_patterns "%TREE% is %ADJ% and also gives nice %THING__" \
    -de '%' -p 'TEST_' "$sentence2"
unset TREE ADJ ADJ_2 THING
