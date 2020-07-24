#!/usr/bin/env fish

function jump_list
  cd $argv
  clear
  ll
  commandline -f repaint
end
