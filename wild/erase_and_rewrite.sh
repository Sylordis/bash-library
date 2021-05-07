#!/usr/bin/env bash

txt="abcdefghijkl"

echo -e "I am a text
$txt
the end\e[1A"

for i in $(seq ${#txt} -1 0); do
  echo -e "\e[1A\e[K${txt:0:$i}"
  sleep 0.25
done
