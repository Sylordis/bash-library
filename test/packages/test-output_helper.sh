#! /usr/bin/env bash

# Helpers
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_PACKS/output_helper.sh"

# Test method
test_outputHelper() {
  local _expected _result
  _expected=$(echo -e "$1")
  shift
  _result="$(eval "$@")"
  assert "$_expected" "$_result"
}

# # Colours
# test_outputHelper '' 'color foo'
# test_outputHelper 'foo' 'color 3.6 foo'
# test_outputHelper "\e[36mfoo\e[0m" 'color 36 foo'
# test_outputHelper "\e[31merror\e[0m" 'cerror error'
# COLOR_ERROR=90
# test_outputHelper "\e[90merror\e[0m" 'cerror error'
# unset COLOR_ERROR
# test_outputHelper "\e[32msuccess\e[0m" 'csuccess success'
# COLOR_SUCCESS=97
# test_outputHelper "\e[97msuccess\e[0m" 'csuccess success'
# unset COLOR_SUCCESS
# test_outputHelper "\e[93munknown\e[0m" 'cunknown unknown'
# COLOR_UNKNOWN=95
# test_outputHelper "\e[95munknown\e[0m" 'cunknown unknown'
# unset COLOR_UNKNOWN
# # Other colours will not be tested as they are just shortcuts according to bash
# # basic colouring
#
# # margin
# echo 'margin'
# test_outputHelper '' margin bar
# test_outputHelper '' margin bar
# test_outputHelper '' margin 0.3
# test_outputHelper '   ' margin 3
# test_outputHelper '          ' margin 10
# test_outputHelper '::' margin 2 ':'
#
# # tabs
# echo 'tab'
# test_outputHelper '' tab 0.3
# test_outputHelper '' tab test
# test_outputHelper '     ' tab
# test_outputHelper '          ' tab 2
# TAB_LENGTH=3
# test_outputHelper '   ' tab
# test_outputHelper '         ' tab 3
# unset TAB_LENGTH
#
# # Columns
# echo 'print_column'
# test_outputHelper '                                 ' print_column
# test_outputHelper 'hello                            ' print_column hello
# test_outputHelper 'hello world 0.3$                 ' print_column hello world 0.3$
# COLUMN_SIZE=20
# test_outputHelper 'test                   ' print_column test
# unset COLUMN_SIZE
# COLUMNS_PADDING=5
# test_outputHelper 'message                            ' print_column message
# unset COLUMNS_PADDING
# # -r option
# test_outputHelper '                        righty   ' print_column -r righty
# # -s option
# test_outputHelper 'beautiful world             ' print_column -s 25 beautiful world
# test_outputHelper "This is way too long   " print_column -s 10 -r This is way too long
# # -r and -s
# test_outputHelper '        this is a message   ' print_column -s 25 -r this is a message
#
# # align_left
# echo 'align_left'
# test_outputHelper '' align_left
# test_outputHelper '' align_left foo
# test_outputHelper '' align_left 0.5 foo
# test_outputHelper 'foo' align_left 0 foo
# test_outputHelper 'message   ' align_left 10 message
# test_outputHelper 'this is a message' align_left 10 this is a message
# test_outputHelper 'this is a message   ' align_left 20 this is a message

# align_center
echo 'align_center'
test_outputHelper '' align_center
test_outputHelper '' align_center foo
test_outputHelper '' align_center 0.5 foo
test_outputHelper 'foo' align_center 0 foo
test_outputHelper '  message ' align_center 10 message
test_outputHelper 'this is a message' align_center 10 this is a message
test_outputHelper '  this is a message  ' align_center 21 this is a message
#
# # align_right
# echo 'align_right'
# test_outputHelper '' align_right
# test_outputHelper '' align_right foo
# test_outputHelper '' align_right 0.5 foo
# test_outputHelper 'foo' align_right 0 foo
# test_outputHelper '   message' align_right 10 message
# test_outputHelper 'this is a message' align_right 10 this is a message
# test_outputHelper '   this is a message' align_right 20 this is a message
