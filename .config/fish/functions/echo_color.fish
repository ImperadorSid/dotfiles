#!/usr/bin/env fish
function echo_color
  string length -q $argv[1]; or set argv[1] 'normal'
  set_color (string split ' ' -- $argv[1]); or return 1

  echo $argv[2..-1]

  set_color normal

  return 0
end

