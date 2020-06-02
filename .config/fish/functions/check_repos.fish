#!/usr/bin/env fish

function check_repos
  set current_directory $PWD
  set have_changed false
  $repositories

  for r in *
    set git_status (g -C $r status -s)

    test -n "$git_status"
    and printf '%s%s%s\n' (set_color green) "$r" (set_color normal)
    and git -C $r status
    and echo
    and set have_changed true
  end

  $have_changed; or echo 'All repository are fully synched'
  $current_directory
end
