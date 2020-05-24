#!/usr/bin/env fish

for i in (seq (count $argv))
  test "x$argv[$i]" = 'x-x' -o "x$argv[$i]" = 'x--'; and set argv[$i] '-e'
end

alacritty $argv
