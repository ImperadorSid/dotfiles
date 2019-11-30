#!/usr/bin/env fish
function system_file
    set file_path $argv[1]
    set file_dir (dirname $file_path)

    set out_dir ~/Downloads/Linux/Linux/system-files

    s mkdir -p $file_dir
    sv $file_path

    mkdir -p $out_dir/$file_dir
    s cp $file_path $out_dir/$file_dir

    commit_repo $out_dir

end
