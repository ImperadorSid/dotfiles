#!/usr/bin/env fish

function install_node
  test -n "$argv"; or return

  set file_name "node-v$argv-linux-x64"

  set tar_files ~/*.xz
  test -n "$tar_files"; and rm -f $tar_files

  a2 -q -d ~ "https://nodejs.org/dist/v$argv/$file_name.tar.xz"
  
  tar xf ~/$file_name.tar.xz
  rm -rf ~/node
  mv ~/$file_name ~/node
end

