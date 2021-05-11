#! /usr/bin/env bash

# Test includes
source "$SH_PATH_UTILS/testing_framework.sh"

# Sources
source "$SH_PATH_LIB/find_dirs.sh"

test_findAllDir() {
  test_and_assert --fnc find_dirs -An "$@"
}

working_directory_create A B C D E A/{F,G,H}
# working_directory_print

test_findAllDir $'A\nB\nC\nD\nE' "$(WD_path)/"
test_findAllDir $'A\nD\nE' "$(WD_path)/" B C
test_findAllDir $'' "$(WD_path)/C"
test_findAllDir $'' "$(WD_path)/C" A B
test_findAllDir $'F\nG\nH' "$(WD_path A)"
test_findAllDir $'G\nH' "$(WD_path A)" C F
test_findAllDir "%%ERROR_DIR_NOT_FOUND%% $(WD_path haha)" "$(WD_path haha)" C D
test_findAllDir "usage: find_dirs <path> [folders-exclusion..]"

working_directory_delete
