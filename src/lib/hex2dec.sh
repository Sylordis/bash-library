#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Calculates the decimal representation of an hex number. This method uses bc.
# Params:
#   $1    <hex> Hex string to put to decimal
# Returns:
#   The decimal version
#------------------------------------------------------------------------------
hex2dec() {
  echo "ibase=16; $1" | bc
}
