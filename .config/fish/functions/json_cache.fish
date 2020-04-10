#!/usr/bin/env fish

function json_cache
  # Parsing arguments
  argparse -n 'JSON Cache' -x 'f,c' -X 1 'f/force' 'c/clean' -- $argv
  if test $status -ne 0; return 1; end

  # Set variables
  set -g cache_dir ~/.cache/fish_json
  set -g index_file $cache_dir/index.json

  if set -q _flag_f
    if not __json_cache_check_uri $argv; return 2; end
    if not __json_cache_check_content_type $argv; return 4; end
    if not __json_cache_download_json $argv; return 3; end

  else if set -q _flag_c
    __json_cache_reset_cache

  else
    if not __json_cache_check_uri $argv; return 2; end
    if not __json_cache_check_content_type $argv; return 4; end

  end

  set -e cache_dir
  set -e index_file
  return 0
end

function __json_cache_check_uri
  if string match -qrv '.+\..+' "$argv"
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

function __json_cache_download_json
  set fixed_uri (__json_cache_add_uri_prefix $argv)
  set next_slot (jq 'length' $index_file)

  if not curl -sLo $cache_dir/$next_slot.json $fixed_uri
    echo 'Download failed'
    return 1
  end
  
  set tmp_file /tmp/json-cache-(date +%N)
  jq ". + [\"$fixed_uri\"]" $index_file > $tmp_file
  mv $tmp_file $index_file

  jq '.' $cache_dir/$next_slot.json
  return 0
end

function __json_cache_reset_cache
  rm $cache_dir/*
  echo '[]' > $index_file
  echo 'Cache directory reseted'
end

function __json_cache_check_content_type
  set content_type (curl -LIsw '%{content_type}' -o /dev/null $argv | sed -nr 's/(.*)(;.*|$)/\1/p')
  if test "$content_type" != 'application/json'
    echo 'This URI doesn\'t link to a JSON file'
    echo "Content-Type: '$content_type'"
    return 1
  end
  return 0
end 

