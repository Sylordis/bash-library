#! /bin/bash

# Helpers includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
# Create mock of source without the /dev/tty
MOCK="prompt_yes_no"
mocks_create "$SH_PATH_LIBS/prompt_yes_no.sh" "$MOCK" tty read
source "$(mocks_get "$MOCK")"

test_promptYesNo() {
  test_and_assert --fnc prompt_yes_no -An +psr'?' --feed "$1" "${@:2}"
}

test_promptYesNo \
    "y" \
    $'Question: do you agree [y/n]? ?0' \
    "Question: do you agree [y/n]?"
test_promptYesNo \
    "n" \
    $'Question: do you agree [y/n]? ?1' \
    "Question: do you agree [y/n]?"
test_promptYesNo \
    "a\nn" \
    $'Question: do you agree [y/n]? \n\'a\' is not a correct answer.\nQuestion: do you agree [y/n]? ?1' \
    "Question: do you agree [y/n]?"
test_promptYesNo \
    "n" \
    $'Question: do you still agree [y/n]? ?1' \
    "Question: do you still agree [y/n]?" "You failed to answer correctly"
test_promptYesNo \
    "b\ny" \
    $'Question: do you still agree [y/n]? \nYou failed to answer correctly\nQuestion: do you still agree [y/n]? ?0' \
    "Question: do you still agree [y/n]?" "You failed to answer correctly"
test_promptYesNo \
    "c\nn" \
    $'Question: ... [y/n]? \nYou failed to answer correctly: c is WRONG\nQuestion: ... [y/n]? ?1' \
    "Question: ... [y/n]?" \
    "You failed to answer correctly: __ANSWER__ is WRONG" "__ANSWER__"

mocks_delete "$MOCK"
