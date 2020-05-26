#!/usr/bin/env fish

function commit_repo
  argparse -n 'Commit Repository' -x 'n,h' 'n/no-push' 'h/help' -- $argv
  test "$status" -eq 0; or return

  set -q _flag_help; and __commit_repo_help; and return

  test -n "$argv"; and set repo_dir $argv; or set repo_dir $PWD
  set current_directory $PWD
  $repo_dir

  set git_status (g status -s)
  if test -n "$git_status"
    read -p "echo_color 'green' -n 'Commit message: '" message
    test -n "$message"; and g add -A; and g commit -qm $message; or return

    if not set -q _flag_no_push
      read -p "echo_color 'blue' -n 'Make push? '; echo -n '[Y/n] '" choice
      test "$choice" = 'n'; or push_repo
    end
  else
    echo 'Nothing to commit'
  end

  $current_directory
end

function __commit_repo_help
  echo 'Commit interactively a git repository

Usage:
  commit_repo [-n] [<repository_folder>]
  commit_repo -h

Options:
  -n, --no-push   Do not push changes after commit
  -h, --help      Show this help'
end

