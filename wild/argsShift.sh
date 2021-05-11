#! /usr/bin/env bash

#echo "Hello World, I am $USER at $HOST, nice to meet you!"

testy() {
  shift
  echo $*
}

echo $*
shift
echo $*
testy $*
echo $*
