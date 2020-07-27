#!/usr/bin/env fish

function jump_list
  cd $argv
  c
  pwd
  commandline -f repaint

  set project (lsd --no-symlink | fzf-tmux -p 30,30 -x 0 -y 31 --layout=reverse --cycle)
  test -n "$project"; and cd $project
end
