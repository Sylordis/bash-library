#! /bin/bash

#==============================================================================
# This is a launcher for all unit tests in this repository.
# It will scan all files starting with "test-" and run them.
#==============================================================================

source ".launcher_profile_safe"
source "$SH_PATH_LIB/fill_line.sh"
source "$SH_PATH_PACKS/output_helper.sh"
source "$SH_DEBUG"

# Get test name based on pattern
get_test_name() {
  basename "$1" | sed -re 's/test-(.*).sh/\1/g'
}

# Footer
goodbye() {
  cbold "$(fill_line "80" "=" "EXITING BASH UNIT-TESTING LAUNCHER ")"
}

# Gets a list of all tests per directory in SH_PATH_TEST
list_all_tests() {
  local test_dir test_file
  echo -e "\nList of available tests files:"
  while read test_dir; do
    echo "${test_dir##$SH_PATH_TEST/}:"
    while read test_file; do
      echo -en "  - \e[94m$(get_test_name "$test_file")\e[0m "
      local ntests nasserts
      nasserts="$(grep -c '^assert.*' "$test_file")"
      ntests="$(grep -c "^test_.*[^{]$" "$test_file")"
      ntests=$((ntests+nasserts))
      echo -e "\e[2m($ntests tests)\e[0m"
    done < <(find "$test_dir" -type f -name 'test-*.sh')
  done < <(find "$SH_PATH_TEST" -mindepth 1 -type d)
}

# Prints a line with the test name
print_test_name() {
  color "1;93" "$(fill_line 60 "-" "Testing '$(get_test_name "$1")' ")"
}

# Header
welcome() {
  cbold "$(fill_line "80" "=" "BASH UNIT-TESTING LAUNCHER ")"
}

#==================================================================================================
# MISC VARIABLES
#==================================================================================================
TRUE=0
FALSE=1

SUMMARY=$FALSE
ALL_TESTS=()

#==================================================================================================
# MAIN
#==================================================================================================

# Arguments parsing
while :
do
  case "$1" in
    --summary|-s) SUMMARY=$TRUE;;
    --list|-l) welcome; list_all_tests; goodbye; exit 0;;
    *) break;;
  esac
  shift
done

welcome

# If arguments, do only mentionned tests
if [[ $# -gt 0 ]]; then
  for t; do
    # Check if test exists
    test_file="$(find "$SH_PATH_TEST" -type f -name "test-$t.sh")"
    if [[ -f "$test_file" ]]; then
      ALL_TESTS=("${ALL_TESTS[@]}" "$test_file")
    else
      echo -e "ERROR: Test '$1' does not exist."
      echo -e "    $(cdim "File: test-$t.sh")"
    fi
  done
else
  # Do all tests
  ALL_TESTS=($(find "$SH_PATH_TEST" -type f -name "test-*.sh" | sort))
  echo "Tests files that will be processed: ${#ALL_TESTS[@]}"
fi

# Exit if no tests (but that should never happen right?)
if [[ ${#ALL_TESTS[@]} -eq 0 ]]; then
  echo -e "\nAwwwww, there are no tests to launch... =("
  goodbye
  exit 0
fi

echo "" # lisibility

# Launch all tests
for test in "${ALL_TESTS[@]}"; do
  print_test_name "$test"
  # debug test
  # continue
  # Launch test, redirect output to terminal
  if [[ $SUMMARY -eq $FALSE ]]; then
    $test
  else
    $test | tail -n 2
  fi
  echo "" # lisibility
done

goodbye
