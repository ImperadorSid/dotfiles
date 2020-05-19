#!/usr/bin/env fish

function echo_err
  printf '%sERROR: %s' (set_color brred) (set_color normal)

  if string match -qr '^\d+$' -- "$argv[-1]"
    echo $argv[1..-2]
    return $argv[-1]
  else
    echo $argv
    return 1
  end
end

