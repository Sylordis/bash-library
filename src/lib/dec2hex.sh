#! /usr/bin/env bash

#------------------------------------------------------------------------------
# Calculates the hexadecimal representation of a decimal number.
# This method uses bc.
# Params:
#   $1    <decimal> Decimal number to put in hexadecimal
# Returns:
#   The hexadecimal number
#------------------------------------------------------------------------------
dec2hex() {
  echo "obase=16; $1" | bc
}
