#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/print_result.sh"

test_printResult() {
  test_and_assert --fnc print_result --exp-colours -Al "$@"
}

default_failure="\e[31mfailure\e[0m"
default_success="\e[32mdone\e[0m"

# Testing default
test_printResult "$default_success" 0
test_printResult "$default_failure" 1
test_printResult "$default_failure" 255

# Testing prefixes
test_printResult "testy$default_success" -ps "testy" 0
test_printResult "$default_failure" -ps "testy" 1
test_printResult "testy$default_failure" -pf "testy" 1
test_printResult "$default_success" -pf "testy" 0
test_printResult "testy$default_failure" -p "testy" 1
test_printResult "testy$default_success" -p "testy" 0

# Testing messages
test_printResult "testyYeah!" -ms "testyYeah!" 0
test_printResult "$default_failure" -ms "testyYeah!" 1
test_printResult "testyOwh!" -mf "testyOwh!" 1
test_printResult "$default_success" -mf "testyOwh!" 0

# Testing suffixes
test_printResult "${default_success}testy" -ss "testy" 0
test_printResult "$default_failure" -ss "testy" 1
test_printResult "${default_failure}testy" -sf "testy" 1
test_printResult "$default_success" -sf "testy" 0
test_printResult "${default_failure}testy" -s "testy" 1
test_printResult "${default_success}testy" -s "testy" 0

# All together!
test_printResult "I am a success indeed!" -p "I am a " -s " indeed!" -ms "success" -mf "failure" 0
test_printResult "I am a $default_failure indeed!" -p "I am a " -s " indeed!" -ms "success" 1
test_printResult "I am a failure indeed!" -p "I am a " -s " indeed!" -ms "success" -mf "failure" 1
test_printResult "I am a $default_success indeed!" -p "I am a " -s " indeed!" -mf "failure" 0

# Rewritten affixes
test_printResult "I am not a success at all" -p "I am a " -ps "I am not a " -s " indeed!" -ss " at all" -ms "success" -mf "success" 0
test_printResult "I am a success indeed!" -p "I am a " -ps "I am not a " -s " indeed!" -ss " at all" -ms "success" -mf "success" 1
