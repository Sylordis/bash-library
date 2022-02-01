#! /usr/bin/env bash

#==============================================================================
# This package simply manages clipboard.
#==============================================================================

#------------------------------------------------------------------------------
# Puts something in the clipboard.
# Params:
#   $*    <txt> Text to put in the clipboard
#------------------------------------------------------------------------------
clip_put() {
  local putcmd='putclip'
  if [[ -n "$(type -P xclip)" ]] && [[ -z "$(type -P putclip)" ]]; then
        putcmd="$(type -P xclip) -sel clip -i"
  fi
  echo "$*" | putclip
}

#------------------------------------------------------------------------------
# Gets text from the clipboard.
#------------------------------------------------------------------------------
clip_get() {
  local getcmd='getclip'
  if [[ -n "$(type -P xclip)" ]] && [[ -z "$(type -P getclip)" ]]; then
        getcmd="$(type -P xclip) -sel clip -o"
  fi
  $getcmd
}
