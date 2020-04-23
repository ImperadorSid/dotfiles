#!/usr/bin/env fish
function repos -d 'Manage repository downloads and script installations'
  set options 'e/edit' 'c/create' 'i/only-install' 'd/only-download'
  argparse -x 'e,c,i,d' -X 2 $options -- $argv
  test $status -ne 0; and return 2

  set -g repo_file $argv[1]
  set -g repo_path "$repositories/$argv[1]"

  if set -q _flag_create;
    echo 'Create'
  else if set -q _flag_edit
    echo 'Edit'
  end

  not __repos_check_file; and return 1
  set repo_type repo_metadata $repo_file '.type'
  __repos_unset
  return 0
end

function __repos_check_file
  if test ! -f $repo_path
    echo 'File doesn\'t exit'
  else if not repo_metadata -c $repo_file
    echo 'Repo metadata is invalid'
  else
    return 0
  end

  __repos_unset
  return 1
end

function __repos_unset
  set -e repo_file
  set -e repo_path
end

