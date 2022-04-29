#! /usr/bin/env bash

#==============================================================================
# This is a launcher for all unit tests in this repository.
# This launched works with all files starting with "test-", matching the actual
# lib or package name and run them.
# Example:
#   lib with file name "mylib.sh" will be identified to "test-mylib.sh"
#==============================================================================

# Source files
source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")/bin/.launcher_profile_safe"
source "$SH_PATH_LIB/fill_line.sh"
source "$SH_PATH_PACKS/output_helper.sh"

#------------------------------------------------------------------------------
# Outputs basic usage.
#------------------------------------------------------------------------------
usage() {
  echo "usage: $(basename "$0") [options] [tests..]"
  fold -sw 80 <<< 'Runs all bash tests in this library (no arguments), specific tests (specified as arguments) or lists all tests (--list).'
  echo 'with options:'
  echo '   --help'
  echo '     Outputs this help message.'
  echo '   -l,--list'
  echo '     Outputs a detailed list of all tests suites without running them.'
  echo '   -s,--summary'
  echo '     Outputs the summary of launched tests without the actual tests run outputs.'
}

#------------------------------------------------------------------------------
# Get test name based on pattern.
# Params:
#   $1    Test to get the name from
#------------------------------------------------------------------------------
get_test_name() {
  basename "$1" | sed -re 's/test-(.*).sh/\1/g'
}

#------------------------------------------------------------------------------
# Prints the exit message.
#------------------------------------------------------------------------------
goodbye() {
  cbold "$(fill_line "80" "=" "EXITING BASH UNIT-TESTING LAUNCHER ")"
}

#------------------------------------------------------------------------------
# Gets a list of all tests per directory in SH_PATH_TEST.
#------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
# Prints a line with the test name.
# Params:
#   $1    Test to get the name from.
#------------------------------------------------------------------------------
print_test_name() {
  color "1;93" "$(fill_line 60 "-" "Testing '$(get_test_name "$1")' ")"
}

#------------------------------------------------------------------------------
# Prints the starting message.
#------------------------------------------------------------------------------
welcome() {
  cbold "$(fill_line "80" "=" "BASH UNIT-TESTING LAUNCHER ")"
}

#==================================================================================================
# MISC VARIABLES
#==================================================================================================
SUMMARY=1
ALL_TESTS=()

#==================================================================================================
# MAIN
#==================================================================================================

# Arguments parsing
while :
do
  case "$1" in
    --help) usage; exit 0;;
    --list|-l) welcome; list_all_tests; goodbye; exit 0;;
    --summary|-s) SUMMARY=0;;
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
      echo -e "ERROR: Test '$1' does not exist." >& 2
      echo -e "    $(cdim "File: test-$t.sh")" >& 2
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

echo

# Launch all tests
for test in "${ALL_TESTS[@]}"; do
  print_test_name "$test"
  # Launch test, redirect output to terminal
  if [[ $SUMMARY -eq 1 ]]; then
    $test
  else
    $test | tail -n 2
  fi
  echo
done

goodbye
