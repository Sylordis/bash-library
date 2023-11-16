#! /usr/bin/env bash

# Sets a clean exit trap to remove civis and applies civis at the beginning.

clean_exit() {
  local ps_exit=$?
  tput cnorm
  exit $ps_exit
}
trap clean_exit INT TERM EXIT QUIT
tput civis
