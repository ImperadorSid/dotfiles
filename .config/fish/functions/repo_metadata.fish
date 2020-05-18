#!/usr/bin/env fish
function repo_metadata
  set options 'n/null' 'c/check'
  argparse -n 'Repository metadata' -s -x 'n,c' $options -- $argv
  test "$status" -ne 0; and return 2

  test ! -f "$repositories/$argv[1]"; and return 1

  set metadata (sed '/^#!/,$d; s/\\\/\\\\\\\\\\\\\\\/g' $repositories/$argv[1])

  if set -q _flag_check
    echo $metadata | jq -e 'has("repo") and has("type")' &> /dev/null
  else if set -q _flag_null
    echo $metadata | jq -e $argv[3] $argv[2] > /dev/null
  else
    echo $metadata | jq -re $argv[3] $argv[2]
  end

  return $status
end

