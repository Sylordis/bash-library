#! /usr/bin/env bash

# Helpers
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
# Create mock of source without the /dev/tty
_MOCK="logging_helper_light"
mocks_create "$SH_PATH_PACKS/logging_helper.sh" "$_MOCK" tty
source "$(mocks_get "$_MOCK")"

# Test method
test_loggingHelperLight() {
  local _expected _result
  _expected="$1"
  shift
  _result="$(eval "$@")"
  assert "$_expected" "$_result"
}

test_loggingHelperLight 'Hello world' 'log "Hello world"'
test_loggingHelperLight '[ERROR] Hello error' 'log_error "Hello error" 2>&1 > /dev/null'
test_loggingHelperLight '[DEBUG] Hello debug' 'log_debug "Hello debug"'
# This one is kind of not regular, but no choice
test_loggingHelperLight '[DEBUG] Hello debug' 'log_debug -u "Hello debug"'
test_loggingHelperLight '[INFO ] Hello info' 'log_info "Hello info"'
test_loggingHelperLight '[WARN ] Hello warn' 'log_warn "Hello warn"'

mocks_delete "$_MOCK"
