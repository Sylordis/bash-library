#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/copy_files_affix.sh"

test_copyFilesAffix() {
  local expected result
  expected="$1"
  shift
  result="$(copy_files_affix "$@" 2>&1)"
  [[ $? -eq 0 ]] && result="${result}$(ls -1 "${@: -1}" 2> /dev/null)"
  assert -n "$expected" "$result"
}

working_directory_create A B target{1..2} -f A/{a,b,c} B/{a,b,c,patt_{d,e,f}}
test_copyFilesAffix 'ERROR[copy_files_affix]: Not enough arguments.' 
test_copyFilesAffix 'ERROR[copy_files_affix]: Not enough arguments.' "$(WD_path)"
test_copyFilesAffix "$(TEST_error 'NO_FILE_OR_DIR' 'cp' "$(WD_path)/C/*")" "$(WD_path)/C"/* "$(WD_path)/target1"
test_copyFilesAffix $'a\nb\nc' "$(WD_path)/A"/* "$(WD_path)/target1"
test_copyFilesAffix $'patt_d\npatt_e\npatt_f' "$(WD_path)/B"/patt_* "$(WD_path)/target2"
WD_delete

working_directory_create A B target{3..5} -f A/{a,b,c} B/{a,b,c,patt_{d,e,f}}
# Prefix tests
test_copyFilesAffix $'h_a\nh_b\nh_c' --prefix=h_ "$(WD_path)/A"/* "$(WD_path)/target3"
test_copyFilesAffix $'1a\n2b\n3c' --prefix=numbered "$(WD_path)/A"/* "$(WD_path)/target4"
test_copyFilesAffix $'0001-a\n0002-b\n0003-c\n0004-patt_d\n0005-patt_e\n0006-patt_f' \
    --prefix=numbered:xxxx- "$(WD_path)/B"/* "$(WD_path)/target5"
WD_delete

working_directory_create A B target{6..8} -f A/{a,b,c} B/{a,b,c,d,e,f,g,h,i,j,k}
# Suffix tests
test_copyFilesAffix $'a-e\nb-e\nc-e' --suffix=-e "$(WD_path)/A"/* "$(WD_path)/target6"
test_copyFilesAffix $'a-1\nb-2\nc-3\nd-4\ne-5\nf-6\ng-7\nh-8\ni-9\nj-10\nk-11' \
    --suffix=numbered:- "$(WD_path)/B"/* "$(WD_path)/target7"
test_copyFilesAffix $'a_01\nb_02\nc_03' --suffix=numbered:xx_ "$(WD_path)/A"/* "$(WD_path)/target8"
WD_delete

# Both
working_directory_create A B target9 -f {A,B}/{a,b,c}
test_copyFilesAffix $'001-a_my\n002-b_my\n003-c_my\n004-a_my\n005-b_my\n006-c_my' \
    --prefix=numbered:xxx- --suffix=_my "$(WD_path)/A"/* "$(WD_path)/B"/* "$(WD_path)/target9"
WD_delete
