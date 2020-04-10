#!/usr/bin/env fish

function json_cache
  # Parsing arguments
  if not argparse -x 'f,c' -X 1 'f/force' 'c/clean' -- $argv
    return
  else if test -z $argv
    echo 'Parameter required "URI" not specified'
  end

  # Set variables
  set cache_dir ~/.cache/fish_json
  set index_file $cache_dir/index.json

  if set -q _flag_f
    echo 'Flag F'
    curl -s $argv
  else if set -q _flag_c
    rm $cache_dir/.
    echo '[]' > $index_file

    echo 'Cache directory reseted'
  else
    set next_slot (jq '. | length' $index_file)

    a2 -q $argv -d $cache_dir -o $next_slot.json 
    cat $cache_dir/$next_slot.json
  end
end

