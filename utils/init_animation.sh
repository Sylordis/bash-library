#! /bin/bash

clean_exit() {
  local ps_exit=$?
  tput cnorm
  exit $?
}
trap clean_exit INT TERM EXIT KILL QUIT
tput civis
