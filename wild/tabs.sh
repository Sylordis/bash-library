#! /usr/bin/env bash

# echo "Hello World, I am $USER at $HOST, nice to meet you!"

repo=/tmp/sccfpatch/1111
build=/home/sccfops

count=""
echo -e "\ta\ta\ta\ta\ta\ta\ta\ta"
for i in $(seq 1 1 30); do
  # echo $i | sed -re 's/.*(.)/\1/g'
  count="$count$(echo $i | sed -re 's/.*(.)/\1/g')"
  echo -e "$count\ta"
done

# 7 12  16  20  24  28
# 7 5+2 4+3 4+3 4+3 4+3
# tabs width=7
