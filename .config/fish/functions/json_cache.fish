#!/usr/bin/env fish

function json_cache -d "Make a cache of JSON files to avoid requisition limits"
  # Parsing arguments
  argparse -n 'JSON Cache' -x 'f,c' -X 1 'f/force' 'c/clean' -- $argv
  if test $status -ne 0; return 1; end

  # Set variables
  set -g cache_dir ~/.cache/fish_json
  set -g index_file $cache_dir/index.json

  if set -q _flag_clean
    __json_cache_reset_cache
  else
    if not __json_cache_check_uri $argv; return 2; end
    set -g prefixed_uri (__json_cache_add_uri_prefix $argv)

    set search_result (jq "indices(\"$prefixed_uri\")[0]" $index_file)

    if test $search_result != 'null'
      if set -q _flag_force
        if not __json_cache_check_content_type; return 3; end
        if not __json_cache_download_json $search_result; return 4; end
      end

      jq . $cache_dir/$search_result.json
    else
      set new_entry_id (jq 'length' $index_file)
      
      if not __json_cache_check_content_type; return 3; end
      if not __json_cache_download_json $new_entry_id; return 4; end

      __json_cache_new_entry

      jq . $cache_dir/$new_entry_id.json
    end
  end

  set -e cache_dir
  set -e index_file
  set -e prefixed_uri
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
  set file_id $argv
  if not curl -sLo $cache_dir/$file_id.json $prefixed_uri
    echo 'Download failed'
    return 1
  end
  return 0
end

function __json_cache_reset_cache
  rm -r $cache_dir
  mkdir -p $cache_dir
  echo '[]' > $index_file

  echo 'Cache directory cleared'
end

function __json_cache_check_content_type
  set content_type (curl -LIsw '%{content_type}' -o /dev/null $prefixed_uri | sed -nr 's/(.*)(;.*|$)/\1/p')
  if test "$content_type" != 'application/json'
    echo 'This URI doesn\'t link to a JSON file'
    echo "Content-Type: '$content_type'"
    return 1
  end
  return 0
end 

function __json_cache_new_entry
  set tmp_file /tmp/json-cache-(date +%N)
  jq ". + [\"$prefixed_uri\"]" $index_file > $tmp_file
  mv $tmp_file $index_file
end

