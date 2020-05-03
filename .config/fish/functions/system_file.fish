#!/usr/bin/env fish
function system_file

    set file_path $argv[1]
    set file_dir (dirname $file_path)

    set out_dir $system_files

    sudo mkdir -p $file_dir
    V $file_path

    mkdir -p $out_dir/$file_dir
    sudo cp -r $file_path $out_dir/$file_dir

    commit_repo $out_dir

end
