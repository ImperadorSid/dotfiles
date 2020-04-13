#!/usr/bin/env fish

function push_repo
  set target_dir $argv[1]

  echo -n 'Pushing... '
  if not g -C $target_dir push
      if not g -C $target_dir pull
          for f in (g -C $target_dir diff --name-only --diff-filter=U)
	      vim $target_dir/$f
          end
          commit_repo $target_dir
      end
      g -C $target_dir push -q
  end
  echo 'complete'
end
