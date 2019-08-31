#!/usr/bin/env fish
function system_file
    set file_path $argv[1]
    set file_dir (dirname $file_path)
    set cur_dir $PWD

    set out_dir ~/Downloads/Linux/Linux/system-files

    s mkdir -p $file_dir
    s vim $file_path

    mkdir -p $out_dir/$file_dir
    s cp $file_path $out_dir/$file_dir

    commit_file $out_dir

end
