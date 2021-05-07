#! /bin/bash

# Helpers includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
# Create temporary source without the /dev/tty
MOCK="promptmulti"
mocks_create "$SH_PATH_LIBS/prompt_multi.sh" "$MOCK" tty read
source "$(mocks_get "$MOCK")"

test_promptMulti() {
  test_and_assert --fnc prompt_multi --feed "$1" "${@:2}"
}

# Init
answers=(a b c d e)

# Test no options
test_promptMulti "1\n" "C"
# Test basic
test_promptMulti \
    "1\n" \
    $'Here are the available answers:\n1) a\n2) b\n3) c\n4) d\n5) e\nC) Cancel\nPlease enter your choice(s):\n1' \
    "${answers[@]}"
# Test basic wrong
test_promptMulti \
    "7\n1\n" \
    $'Here are the available answers:\n1) a\n2) b\n3) c\n4) d\n5) e\nC) Cancel\nPlease enter your choice(s):\n<7> is not a correct answer.\nPlease enter your choice(s):\n1' \
    "${answers[@]}"
# Test escape
test_promptMulti \
    "C\n" \
    $'Here are the available answers:\n1) a\n2) b\n3) c\n4) d\n5) e\nC) Cancel\nPlease enter your choice(s):\nC' \
    "${answers[@]}"
# Test try escape with force
test_promptMulti \
    "C\n1\n" \
    $'Here are the available answers:\n1) a\n2) b\n3) c\n4) d\n5) e\nPlease enter your choice(s):\n<C> is not a correct answer.\nPlease enter your choice(s):\n1' \
    -nc "${answers[@]}"
# Test multi without option
test_promptMulti \
    "1,2\n2\n" \
    $'Here are the available answers:\n1) a\n2) b\n3) c\n4) d\n5) e\nC) Cancel\nPlease enter your choice(s):\n<1,2> is not a correct answer.\nPlease enter your choice(s):\n2' \
    "${answers[@]}"

# Test multi basic
test_promptMulti \
    "1,2\n" \
    $'Here are the available answers: (multi-choice)\n1) a\n2) b\n3) c\n4) d\n5) e\nC) Cancel\nPlease enter your choice(s):\n1,2' \
    -mc "${answers[@]}"
# Test multi wrong
test_promptMulti \
    "1,10\n2\n" \
    $'Here are the available answers: (multi-choice)\n1) a\n2) b\n3) c\n4) d\n5) e\nC) Cancel\nPlease enter your choice(s):\n<10> is not a correct answer.\nPlease enter your choice(s):\n2' \
    -mc "${answers[@]}"
# Test multi cancel
test_promptMulti \
    "1,2,3,4,5,C\n" \
    $'Here are the available answers: (multi-choice)\n1) a\n2) b\n3) c\n4) d\n5) e\nC) Cancel\nPlease enter your choice(s):\nC' \
    -mc "${answers[@]}"

# Cleanup
mocks_delete "$MOCK"
