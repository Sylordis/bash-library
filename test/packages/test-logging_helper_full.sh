#! /usr/bin/env bash

# Helpers
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
# Create mock of source without the /dev/tty
_MOCK="logging_helper"
mocks_create "$SH_PATH_PACKS/logging_helper_full.sh" "$_MOCK" tty
source "$(mocks_get "$_MOCK")"

# Test method
test_loggingHelper() {
  local _expected _result
  _expected="$1"
  shift
  _result="$(eval "$@")"
  assert -n "$_expected" "$_result"
}

working_directory_create

logger_configure --level=debug

test_loggingHelper 'Hello world' 'log "Hello world"'
test_loggingHelper '[ERROR] Hello error' 'log_error "Hello error" 2>&1 > /dev/null'
test_loggingHelper '[DEBUG] Hello debug' 'log_debug "Hello debug"'
# This one is kind of not regular, but no choice
test_loggingHelper '[DEBUG] Hello debug' 'log_debug -u "Hello debug"'
test_loggingHelper '[INFO ] Hello info' 'log_info "Hello info"'
test_loggingHelper '[WARN ] Hello warn' 'log_warn "Hello warn"'

# Test level filtering
logger_configure --level=info
test_loggingHelper '' 'log_debug "Hello debug"'
test_loggingHelper '[INFO ] Hello info' 'log_info "Hello info"'

logger_configure --level=error
test_loggingHelper 'Hello world' 'log "Hello world"'

# Test wrong configuration
test_loggingHelper "ERROR[logger]: Unknown output type 'testy', possible values are [BOTH, FILE_ONLY]." "logger_configure --type=testy 2>&1"
test_loggingHelper "ERROR[logger]: Unknown saving method 'testy', possible values are [APPEND, OVERWRITE, SAVE]." "logger_configure --save=testy 2>&1"
test_loggingHelper "ERROR[logger]: Unknown log level 'testy', possible values are [ERROR, WARN, INFO, DEBUG]." "logger_configure --level=testy 2>&1"
test_loggingHelper "ERROR[logger_configure]: unknown setting '--testy'." "logger_configure --testy 2>&1"
test_loggingHelper "ERROR[logger]: Cannot create new log file '/blah/file'." "logger_configure --file=/blah/file 2>&1"

# File
logger_configure --file="$(WD_path "log_file")"
test_loggingHelper $'Hello world\nHello world' "log 'Hello world'; cat '$(WD_path "log_file")'"

# Test save methods
logger_configure --file="$(WD_path "log_file_case1")" --save="save"
echo -n "Checking file saved: "
assert "1" "$(find "$(WD_path)" -type f -name 'log_file_case1' | wc -l)"
# Test multiple saves in a row
logger_configure --file="$(WD_path "log_file_case2")"
logger_configure --file="$(WD_path "log_file_case2")"
logger_configure --file="$(WD_path "log_file_case2")"
echo -n "Checking multiple saves [main]: "
assert "1" "$(find "$(WD_path)" -type f -name 'log_file_case2' | wc -l)"
echo -n "                        [alts]: "
assert "2" "$(find "$(WD_path)" -type f -name 'log_file_case2_*' | wc -l)"

working_directory_clean

# Test output type
logger_configure --save="append" --type="file_only" --file="$(WD_path "log_file")"
test_loggingHelper 'Hello world' "log 'Hello world'; cat '$(WD_path "log_file")'"
test_loggingHelper $'Hello world\nHello world' "log 'Hello world'; cat '$(WD_path "log_file")'"

logger_configure --save="overwrite"
test_loggingHelper 'Overwritten' "log 'Overwritten'; cat '$(WD_path "log_file")'"

logger_configure --type="both"
test_loggingHelper $'And written\nOverwritten\nAnd written' "log 'And written'; cat '$(WD_path "log_file")'"

working_directory_delete
