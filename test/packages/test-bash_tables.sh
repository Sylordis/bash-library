#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_PACKS/bash_tables.sh"

# Errors
test_and_assert --with-errors --fnc table_configure "ERROR[table_configure]: No columns defined for table."
test_and_assert --with-errors --fnc table_configure "ERROR[table_configure]: Unknown flag '-hello'." -hello
test_and_assert --with-errors --fnc table_configure "ERROR[table_configure]: Unknown value 'fiawue' for table border.
ERROR[table_configure]: No columns defined for table." --borders fiawue


table_configure -c=20,15,*,15 --size=80 --calign3=right
assert -n "|h1                |h2            |h3                           |            h4|
+------------------+--------------+-----------------------------+--------------+
|Lorem             |ipsum         |dolor                        |           sit|
|amet,             |consectetur   |adipiscing                   |         elit.|
|Donec             |dapibus       |tellus                       |     volutpat,|
|vestibulum        |lacus         |nec,                         |       aliquam|" \
"$(table_print_line h1 h2 h3 h4
table_print_separator
table_print_line Lorem ipsum dolor sit
table_print_line amet, consectetur adipiscing elit.
table_print_line Donec dapibus tellus volutpat,
table_print_line vestibulum lacus nec, aliquam)"

table_configure -p
assert -n "| h1               | h2           | h3                          | h4           |
+------------------+--------------+-----------------------------+--------------+
| Lorem            | ipsum        | dolor                       | sit          |
| amet,            | consectetur  | adipiscing                  | elit.        |
| Donec            | dapibus      | tellus                      | volutpat,    |
| vestibulum       | lacus        | nec,                        | aliquam      |" \
"$(table_print_line h1 h2 h3 h4
table_print_separator
table_print_line Lorem ipsum dolor sit
table_print_line amet, consectetur adipiscing elit.
table_print_line Donec dapibus tellus volutpat,
table_print_line vestibulum lacus nec, aliquam)"

table_cfg --new --ncols 3 -w 21
assert -n "+-----+------+------+
|a    |b     |c     |
|e    |f     |g     |
|h    |i     |j     |" \
"$(table_print_separator
table_print_line a b c d
table_print_line e f g
table_print_line h i j)"

echo "left padded"
table_cfg -p
assert -n "+-----+------+------+
| a   | b    | c    |
| e   | f    | g    |
| h   | i    | j    |" \
"$(table_print_separator
table_print_line a b c d
table_print_line e f g
table_print_line h i j)"

table_cfg -np --align center
assert -n "+-----+------+------+
|  a  |  b   |  c   |
|  e  |  f   |  g   |
|  h  |  i   |  j   |" \
"$(table_print_separator
table_print_line a b c
table_print_line e f g
table_print_line h i j)"

table_cfg -p
assert -n "+-----+------+------+
|  a  |  b   |  c   |
|  e  |  f   |  g   |
|  h  |  i   |  j   |" \
"$(table_print_separator
table_print_line a b c
table_print_line e f g
table_print_line h i j)"

table_cfg --borders n -np
assert -n "   a      b      c   
   e      f      g   
   h      i      j   " \
"$(table_print_separator
table_print_line a b c
table_print_line e f g
table_print_line h i j)"

table_cfg -p
assert -n "   a      b      c   
   e      f      g   
   h      i      j   " \
"$(table_print_separator
table_print_line a b c
table_print_line e f g
table_print_line h i j)"

# Test overflow
table_cfg --new -c 12,8,*,7 -n 2 -w 50
assert -n "+----------+-------+----------------------+------+
|Lorem     |ipsum  |dolor                 |sit   |
|amet,     |consectetur|adipiscing        |elit. |" \
"$(table_print_separator
table_print_line Lorem ipsum dolor sit
table_print_line amet, consectetur adipiscing elit.)"
