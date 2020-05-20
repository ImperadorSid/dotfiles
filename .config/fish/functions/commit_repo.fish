#!/usr/bin/env fish

function commit_repo
  test -n "$argv"; and set repo_dir $argv; or set repo_dir $PWD
  $repo_dir

  set git_status (g status -s)
  if test -n "$git_status"
    read -p 'echo_color "green" -n "Commit message: "' message
    test -n "$message"; and g add -A; and g commit -qm $message

    read -p 'echo_color "blue" -n "Make push? "; echo -n "[Y/n] "' choice
    test "$choice" = 'n'; or push_repo $repo_dir
  else
    echo 'Nothing to commit'
  end

  cd -
end

