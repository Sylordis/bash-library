#! /usr/bin/env bash

# Helpers includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
# Create temporary source without the /dev/tty
MOCK="log"
mocks_create "$SH_PATH_LIB/log.sh" "$MOCK" tty
source "$(mocks_get "$MOCK")"

test_log() {
  test_and_assert --exp-colours --with-errors --fnc log "$@"
}

# Test standard
test_log "" ""
test_log "standard" "standard"
test_log 'big long word in one string' 'big long word in one string'
test_log 'standard output with multiple words' 'standard' 'output' 'with' 'multiple' 'words'
test_log "\e[34mcoloured\e[0m" "\e[34mcoloured\e[0m"

# Test error
test_log '' -e ''
test_log 'standard_err' -e 'standard_err'
test_log "\e[95mcoloured\e[0m error" -e "\e[95mcoloured\e[0m" 'error'

#Test verbose
test_log '' -v 'should not output anything'
VERBOSE_MODE=0
test_log 'special verb' -v 'special' 'verb'
test_log "\e[93mcoloured verb\e[0m" -v "\e[93mcoloured verb\e[0m"

# Cleanup
mocks_delete "$MOCK"
