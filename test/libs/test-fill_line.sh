#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/fill_line.sh"

test_fillLine() {
  test_and_assert --fnc "fill_line" -Anl "$@"
}

test_fillLine "a-------------------------------------------------------------------------------" 80 - a
test_fillLine "  my title ___________________________________________________________" 70 _ "  my title "
test_fillLine "  // TESTS ON blabla() ---------------------------------------------------------" 80 - "  // TESTS ON blabla() "
test_fillLine "  Babedibupi (_(_(_(_(_(_(_(_(_(_(_(_(_(_(_(_(_(_(_(_(_(_(_" 60 "(_" "  Babedibupi "
test_fillLine "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse ut dolor tempor, dictum erat non, pellentesque sem. Ut rutrum a." 60 "(_" "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse ut dolor tempor, dictum erat non, pellentesque sem. Ut rutrum a."
test_fillLine "I'm a colored title ====================" 40 = "I'm a colored title "
test_fillLine --exp-colours "I'm a \e[32mcolored\e[0m title ====================" 40 = "I'm a \e[32mcolored\e[0m title "
test_fillLine --exp-colours "I'm a \e[1;36mcolored\e[0m title ====================" 40 = "I'm a \e[1;36mcolored\e[0m title "
test_fillLine "oops" 40 "" "oops" # Division by 0 with empty pattern
