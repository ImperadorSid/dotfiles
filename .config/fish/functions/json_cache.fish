#!/usr/bin/env fish

function json_cache -d "Make a cache of JSON files to avoid requisition limits"
  # Parsing arguments
  argparse -n 'JSON Cache' -x 'f,c,h' -X 1 'f/force' 'c/clear' 'h/help' -- $argv
  test "$status" -eq 0; or return

  # Set variables
  set -g cache_dir ~/.cache/fish_json
  set -g indexes_file $cache_dir/index.json

  if set -q _flag_help
    __json_cache_help
  else if set -q _flag_clear
    __json_cache_reset_cache
  else
    if __json_cache_check_uri $argv
      set -g prefixed_uri (__json_cache_add_uri_prefix $argv)

      set file_index (jq "indices(\"$prefixed_uri\")[0]" $indexes_file)

      if test "$file_index" != 'null'
        if set -q _flag_force
          __json_cache_make_download $file_index
        end
      else
        set file_index (jq 'length' $indexes_file)
        __json_cache_make_download $file_index
        and __json_cache_new_entry
      end

      and jq . $cache_dir/$file_index.json
    end
  end

  set exit_code $status
  __json_cache_unset_variables
  return $exit_code
end

function __json_cache_check_uri
  string match -qr '.+\..+' "$argv"
  or echo_err "The argument '$argv' doesn't meet the requirements for URIs" 2
end

function __json_cache_add_uri_prefix
  string match -qrv '^https?://' $argv; and echo "https://$argv"; or echo "$argv"
end

function __json_cache_download_json
  set file_id $argv
  curl -sLo $cache_dir/$file_id.json $prefixed_uri; or echo_err 'Download failed' 4
end

function __json_cache_make_download
  __json_cache_check_content_type
  and __json_cache_download_json $argv
end

function __json_cache_reset_cache
  rm -r $cache_dir
  mkdir -p $cache_dir
  echo '[]' > $indexes_file

  echo 'Cache directory cleared'
end

function __json_cache_check_content_type
  set content_type (curl -LIsw '%{content_type}' -o /dev/null $prefixed_uri | sed -nr 's/(.*)(;.*|$)/\1/p')

  test "$content_type" = 'application/json'
  or echo_err -e 'This URI doesn\'t link to a JSON file\nContent-Type: '$content_type'' 3
end

function __json_cache_new_entry
  set tmp_file (mktemp)
  jq ". + [\"$prefixed_uri\"]" $indexes_file > $tmp_file
  mv $tmp_file $indexes_file
end

function __json_cache_unset_variables
  set -e cache_dir
  set -e indexes_file
  set -e prefixed_uri
end

function __json_cache_help
  echo 'Request and caches JSON requests

Usage:
  json_cache [(-c | -n | -h)] <uri>

Options:
  -c, --clear   Clear cache data
  -f, --force   Force download even if URI is cached
  -h, --help    Show this help'
end

