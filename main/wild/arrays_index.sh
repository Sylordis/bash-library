#! /bin/bash

d_array() {
  echo "d_array($@): $0 $1 $2"
  case $# in
    1) echo "${array[@]:$1}";;
    2) echo "${array[@]:$1:$2}";;
  esac
}

array=(a b c d)
echo "${array[@]}"

d_array 1
d_array 2
d_array 0 3
d_array 0 4
d_array 2 4
d_array 1 0
