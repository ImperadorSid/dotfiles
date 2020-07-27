#!/usr/bin/env fish

function jump_list
  cd $argv
  c
  pwd
  commandline -f repaint

  set project (lsd | fzf-tmux -p 70,15 -x 0 -y 16)
  test -n "$project"; and cd $project
end
