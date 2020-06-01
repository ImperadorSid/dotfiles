#!/usr/bin/env fish

function check_repos
  set current_directory $PWD
  $repositories

  for r in *
    set git_status (g -C $r status -s)

    test -n "$git_status"
    and printf '%s%s%s\n' (set_color green) "$r" (set_color normal)
    and git -C $r status
    and echo
  end

  $current_directory
end
