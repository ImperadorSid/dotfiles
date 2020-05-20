#!/usr/bin/env fish

function commit_repo
  argparse -n 'n/no-push' -- $argv
  test "$status" -eq 0; or return

  test -n "$argv"; and set repo_dir $argv; or set repo_dir $PWD
  set current_directory $PWD
  $repo_dir

  set git_status (g status -s)
  if test -n "$git_status"
    read -p 'echo_color "green" -n "Commit message: "' message
    test -n "$message"; and g add -A; and g commit -qm $message; or return

    if not set -q _flag_no_push
      read -p 'echo_color "blue" -n "Make push? "; echo -n "[Y/n] "' choice
      test "$choice" = 'n'; or push_repo
    end
  else
    echo 'Nothing to commit'
  end

  $current_directory
end

