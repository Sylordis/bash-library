#! /bin/bash

#------------------------------------------------------------------------------
# Calculates the decimal representation of an hex number.
# Params:
#   $1    Hex string to put to decimal
# Returns:
#   The decimal version
#------------------------------------------------------------------------------
hex2dec() {
  echo "ibase=16; $1" | bc
}
