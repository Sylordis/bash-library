#! /bin/bash

#------------------------------------------------------------------------------
# Calculates the hexadecimal representation of a decimal number.
# Params:
#   $1    Decimal number to put in hexadecimal
# Returns:
#   The hexadecimal number
#------------------------------------------------------------------------------
dec2hex() {
  echo "obase=16; $1" | bc
}
