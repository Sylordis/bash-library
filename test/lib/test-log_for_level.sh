#! /usr/bin/env bash

# Helpers includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/log_for_level.sh"

TEST_METHOD="log_for_level"
test_log_for_level() {
  test_and_assert "$@"
}


test_log_for_level "" ""
test_log_for_level "standard" "standard"
test_log_for_level 'big long word in one string' 'big long word in one string'
test_log_for_level 'standard output with multiple words' 'standard' 'output' 'with' 'multiple' 'words'
test_and_assert -Al --exp-colours "\e[34mcoloured\e[0m" "\e[34mcoloured\e[0m"

# Default LOGLEVEL
for level in 0 1 2 3; do
    [[ $level -ge 1 ]] && expected="$level foo"
    test_log_for_level "$expected" $level "$level foo"
done
for LOGLEVEL in 0 1 2 3 4; do
    for level in 0 1 2 3 4; do
        [[ $level -ge $LOGLEVEL ]] && expected="$level >? $LOGLEVEL"
        test_log_for_level "$expected" $level "$level >? $LOGLEVEL"
        unset expected
    done
done
