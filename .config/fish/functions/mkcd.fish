#!/usr/bin/env fish

function mkcd
  mkdir -p $argv
  and cd $argv
end

