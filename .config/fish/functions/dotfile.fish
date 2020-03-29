#!/usr/bin/env fish

function dotfile
    set file_path $argv[1]
    set file_dir (dirname $file_path)
	
    set out_dir $dotfiles

    mkdir -p ~/$file_dir
    v ~/$file_path

    mkdir -p $out_dir/$file_dir
    cp -r ~/$file_path $out_dir/$file_dir

    commit_repo $out_dir
end
