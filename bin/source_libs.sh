#!/usr/bin/env bash

source "$SH_PATH/bin/.launcher_profile_safe"

# Sources all libs and completion
while read file; do
  source "$file"
done < <(find "$SH_PATH_LIB" -type f -name '*.sh')
while read file; do
  source "$file"
done < <(find "$SH_PATH_COMPL" -type f -name '*.sh')
unset file
