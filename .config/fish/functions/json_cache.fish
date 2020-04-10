#!/usr/bin/env fish

function json_cache
  # Parsing arguments
  argparse -n 'JSON Cache' -x 'f,c' -X 1 'f/force' 'c/clean' -- $argv
  if test $status -ne 0; return 1; end

  # Set variables
  set cache_dir ~/.cache/fish_json
  set index_file $cache_dir/index.json

  if set -q _flag_f
    if not __json_cache_check_uri $argv; return 2; end
    echo 'Flag F'

    if not curl -s $argv
      echo 'Download failed'
      return 3
    end

  else if set -q _flag_c
    rm $cache_dir/*
    echo '[]' > $index_file

    echo 'Cache directory reseted'

  else
    if not __json_cache_check_uri $argv; return 2; end
    set next_slot (jq '. | length' $index_file)

    if not a2 -q --allow-overwrite -d $cache_dir -o $next_slot.json (__json_cache_add_uri_prefix $argv)
      echo 'Download failed'
      return 3
    end
    jq '.' $cache_dir/$next_slot.json
  end
end

function __json_cache_check_uri
  if string match -qrv '.+\..+' $argv
    echo "The argument '$argv' doesn't meet the requirements for URIs"
    return 1
  end
  return 0
end

function __json_cache_add_uri_prefix
  if string match -qrv '^https?://' $argv
    echo "https://$argv"
  else
    echo "$argv"
  end
end

