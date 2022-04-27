#! /usr/bin/env bash

source "$DEBUG"

# echo "Hello mate! Nothing to see here!"

varA=a

if [[ -z "${varA+x}" ]]; then
  echo "varA is not set."
else
  echo "varA is set."
fi

if [[ -z "${!varA+x}" ]]; then
  echo "${varA} is not set."
else
  echo "${varA} is set."
fi

a=b
if [[ -z "${!varA+x}" ]]; then
  echo "${varA} is not set."
else
  echo "${varA} is set."
fi
unset a

a=()
if [[ -z "${!varA+x}" ]]; then
  echo "${varA} is not set."
else
  echo "${varA} is set."
fi
