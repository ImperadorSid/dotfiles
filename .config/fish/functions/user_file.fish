#!/usr/bin/env fish
function user_file
    set file_path $argv[1]
    set file_dir (dirname $file_path)
    set cur_dir $PWD
	
    set out_dir ~/Downloads/Linux/Linux/user-files

    mkdir -p ~/$file_dir
    vim ~/$file_path

    mkdir -p $out_dir/$file_dir
    cp ~/$file_path $out_dir/$file_dir

    commit_repo $out_dir
end
