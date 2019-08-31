#!/usr/bin/env fish

function commit_repo
    set cur_dir $PWD
    set out_dir $argv[1]
    
    read -p 'set_color green; echo -n \'Commit message\'; set_color normal; echo \': \'' msg
    if test -n $msg
	cd $out_dir
        g add .
        g commit -m $msg
	cd $cur_dir 
    end

end

