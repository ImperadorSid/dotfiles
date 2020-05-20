#!/usr/bin/env fish

function push_repo
  test -n "$argv"; and set target_dir $argv; or set target_dir $PWD
  set current_directory $PWD
  $target_dir

  if not __push_repo_make_push
    if not loading g pull
      v $target_dir/(g diff --name-only --diff-filter=U)
      commit_repo
    else
      __push_repo_make_push
    end
  end

  $current_directory
end

function __push_repo_make_push
  printf 'Pushing... '
  loading g push -q
  and echo 'complete'
end

