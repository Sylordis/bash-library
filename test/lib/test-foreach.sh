#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"
source "$SH_PATH_UTILS/working_directory.sh"

# Sources
source "$SH_PATH_LIB/foreach.sh"

test_foreach() {
  pushd "$(WD_get_path)" &> /dev/null
  test_and_assert --exp-colours --fnc foreach -An "$@"
  popd &> /dev/null
}
test_foreach_tree() {
  pushd "$(WD_get_path)" &> /dev/null
  test_and_assert --exp-colours --fnc foreach -An "$@"
  popd &> /dev/null
}
test_forgit() {
  pushd "$(WD_get_path)" &> /dev/null
  test_and_assert --exp-colours --fnc forgit -An "$@"
  popd &> /dev/null
}

c_blue() { echo -e "\e[94m$1\e[0m"; }

WD_create A B C -f A/a B/b C/c

test_foreach "$(c_blue "./A"):\n$(c_blue "./B"):\n$(c_blue "./C"):"
test_foreach \
    "$(c_blue "./A"):\na\n$(c_blue "./B"):\nb\n$(c_blue "./C"):\nc" \
    "ls"
test_foreach \
    "$(c_blue "./A"):\nfoo\n$(c_blue "./B"):\nfoo\n$(c_blue "./C"):\nfoo" \
    echo foo
test_foreach \
    "$(c_blue "./A"):\n$(c_blue "./B"):\n$(c_blue "./C"):" \
     touch newfile
assert \
    $'./A/a\n./A/newfile\n./B/b\n./B/newfile\n./C/c\n./C/newfile' \
    "$(WD_print -f)"

WD_delete

WD_create A B C
test_foreach \
  "$(c_blue "./A"):\n$(c_blue "./B"):\n$(c_blue "./C"):" \
  -e "echo '__DIR__:hello' > testy"
assert $'A:hello\nB:hello\nC:hello' "$(find "$(WD_path)" -name 'testy' | xargs cat)"
WD_delete

# Forgit alias, testing only basic functionality as forgit calls foreach
WD_create A/{A1,.git} B C/.git
test_forgit "$(c_blue "./A"):\n$(c_blue "./C"):"
WD_delete
