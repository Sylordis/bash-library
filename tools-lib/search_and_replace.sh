#! /usr/bin/env bash

#------------------------------------------------------------------------------
# This function allows to look for all files containing a certain string and
# replace all occurrences of this string in the found files.
# It is recommended to put an alias for the function (ex: "snr").
# Params:
#   $1  Pattern to look for in the files
#   $2  Replacement for the pattern in the files
# Dependencies:
#   ripgrep, sed, tee, xargs
#------------------------------------------------------------------------------
search_and_replace() {
  rg -l --color=never "$1" | tee /dev/tty | xargs sed -i -re "s%$1%$2%g"
}
