#! /bin/bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIBS/strip_color_tags.sh"

test_stripColorTags() {
  echo -e "Line: $txt"
  test_and_assert --fnc strip_color_tags -Anl "$@"
  # local expected="$1"
  # shift
  # local result
  # result="$(strip_color_tags "$@")"
  # assert -n -l "$expected" "$result"
}

txt="I'm not colored"
test_stripColorTags "$txt" "$txt"

txt="I'm \e[34mblue\e[0m dabedidabeda"
test_stripColorTags "I'm blue dabedidabeda dabedidabeda" "$txt" 'dabedidabeda'

txt="\033[32mGreen\e[0m \x1B[1mbold\e[0m \e[31mred\e[0m!"
test_stripColorTags "Green bold red!" "$txt"

txt="\033[32mGreen\e[0m\n\x1B[1mbold\e[0m\n\e[31mred\e[0m!"
test_stripColorTags $'Green\nbold\nred!' "$txt"
