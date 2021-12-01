#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"
source "$SH_PATH_UTILS/working_directory.sh"

# Sources
source "$SH_PATH_LIB/foreach.sh"

test_foreach() {
  pushd "$(WD_get_path)" &> /dev/null
  test_and_assert --exp-colours --with-errors --fnc foreach -An "$@"
  popd &> /dev/null
}
test_forgit() {
  pushd "$(WD_get_path)" &> /dev/null
  test_and_assert --exp-colours --fnc forgit -An "$@"
  popd &> /dev/null
}

c_blue() { echo -e "\e[94m$1\e[0m"; }
c_red() { echo -e "\e[31m$1\e[0m"; }

WD_create A B C -f A/a B/b C/c
test_foreach "./A:\n./B:\n./C:"
# Test basic command
test_foreach \
    "./A:\na\n./B:\nb\n./C:\nc" \
    ls
# Test quiet -q option
test_foreach "a\nb\nc" \
    -q ls
# Test information command
test_foreach \
    "./A:\nfoo\n./B:\nfoo\n./C:\nfoo" \
    echo foo
# Test of -c
test_foreach \
    "$(c_blue "./A"):\na\n$(c_blue "./B"):\nb\n$(c_blue "./C"):\nc" \
    -c ls
WD_delete

WD_create A B C -f A/a B/b C/c
# Test folder modification
test_foreach \
    "./A:\n./B:\n./C:" \
     touch newfile
assert \
    $'./A/a\n./A/newfile\n./B/b\n./B/newfile\n./C/c\n./C/newfile' \
    "$(WD_print -f)"
WD_delete

WD_create A B C
# Test usage of __DIR__
test_foreach \
  "./A:\n./B:\n./C:" \
  -e "echo '__DIR__:hello' > testy"
assert $'A:hello\nB:hello\nC:hello' "$(find "$(WD_path)" -name 'testy' | xargs cat)"
WD_delete

WD_create A/{A1,A2} B
# Test of failure -f option
err="$(TEST_error 'NO_FILE_OR_DIR' touch '*1/newfile')"
test_foreach \
    "./A:\n$err\n./B:\n$err\n\nFailures[2]: ./A ./B" \
    -f touch '*1/newfile'
# With colour
test_foreach \
    "$(c_blue "./A"):\n$err\n$(c_blue "./B"):\n$err\n\n$(c_red "Failures[2]:") ./A ./B" \
    -fc touch '*1/newfile'
# With quiet
test_foreach \
    "$err\n$err\nFailures[2]: ./A ./B" \
    -f -q touch '*1/newfile'
unset err
WD_delete

WD_create A/{A1,A2} B
# # Test of -s TODO
# date_start="$(date '%s')"
# test_foreach \
#     "./A:\na\n./B:\nb\n./C:\nc" \
#     -s 1 ls
# date_end="$(date '%s')"
# Test of -s error
test_foreach \
    "ERROR[foreach]: option -s expects positive integer argument (was 'ls')." \
    -s ls
test_foreach \
    "ERROR[foreach]: option -s expects positive integer argument (was '-1')." \
    -s -1
test_foreach \
    "ERROR[foreach]: option -s expects an argument." \
    -s
# WD_delete

WD_create A/{A1,A2} B -f A/foo B/bar
# Test of getopts
test_foreach \
    $'A1\nA2\nfoo\nbar' \
    -qc ls -1
WD_delete
