#!/usr/bin/env fish

function update_eslint_config
  for file in .eslintrc.json .eslintignore
    cp $file ~
    cp $file ~/Documents/Programs/Node.js/_configs
    bdot ~/$file
  end
end

