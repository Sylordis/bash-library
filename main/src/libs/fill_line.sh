#! /bin/bash

#------------------------------------------------------------------------------
# Fills a line with a repeated pattern until the line matches the length
# requirement. The last column will be excluded. This method has the backslash
# interpretation enabled.
# Params:
#   $1    Final length (last column excluded)
#   $2    Filling pattern
#   $3    Text to fill
# Returns:
#   The filled line, or the given text if it's longer than the final length
#   requested.
#------------------------------------------------------------------------------
fill_line() {
  local curr_size pattern_size remaining_size vanilla_title title="$3"
  # Strip color tags to calculate how much filling is needed
  vanilla_title="$(echo -e "$title" | sed -r "s,\x1B\[[0-9;]*[mK],,g")"
  curr_size="${#vanilla_title}"
  pattern_size="${#2}"
  remaining_size=$(($1-curr_size))
  if [[ $remaining_size -gt 0 ]] && [[ $pattern_size -gt 0 ]]; then
    local number_of_filling=$((remaining_size/pattern_size))
    for _ in $(seq 1 1 $number_of_filling); do
      title="$title$2"
    done
  fi
  echo -e "$title"
}
