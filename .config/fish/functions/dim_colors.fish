#!/usr/bin/env fish
function dim_colors
  if test (count $argv) -ne 2
    echo 'Wrong arguments count'
    echo 'Command usage: <#RRGGBB> <opacity>'
    return 1
  end

  set result '#'
  for i in (seq 2 2 6)
    set color (string sub -s $i -l 2 $argv[1])
    set new_color_dec (math "round(0x$color * $argv[2])")
    set new_color_hex (printf '%02x' $new_color_dec)
    
    set result (string join '' $result$new_color_hex)
  end

  echo $result
  return 0
end

