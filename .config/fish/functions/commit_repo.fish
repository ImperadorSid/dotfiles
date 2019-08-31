#!/usr/bin/env fish

function commit_repo
    set out_dir $argv[1]
    
    read -p 'set_color green; echo -n \'Commit message\'; set_color normal; echo \': \'' msg
    if test -n $msg
        g -C $out_dir add .
        g -C $out_dir commit -m $msg
    end

end

