#! /usr/bin/env bash

#==============================================================================
# This package simply manages clipboard.
#==============================================================================

# Puts something in the clipboard
clip_put() {
  echo "$*" | putclip
}

# Gets text from the clipboard
clip_get() {
  getclip
}
