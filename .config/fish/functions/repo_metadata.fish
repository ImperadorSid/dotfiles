#!/usr/bin/env fish

function repo_metadata
  set options 'n/null' 'c/check' 'h/help'
  argparse -n 'Repository metadata' -s -x 'n,c,h' $options -- $argv
  test "$status" -eq 0; or return 2

  set -q _flag_help; and __repo_metadata_help; and return

  test ! -f "$repositories/$argv[1]"; and return 1

  set metadata (sed '/^#!/,$d; s/\\\/\\\\\\\\\\\\\\\/g' $repositories/$argv[1])

  if set -q _flag_check
    echo $metadata | jq -e 'has("repo") and has("type")' &> /dev/null
  else if set -q _flag_null
    echo $metadata | jq -e "$argv[2]" > /dev/null
  else
    echo $metadata | jq -re "$argv[2]"
  end
end

function __repo_metadata_help
  echo 'Show metadata of a repository file

Usage:
  repo_metadata [-n] <repository> [<filter>]
  repo_metadata -c <repository>
  repo_metadata -h

Options:
  -n, --null    Do not output anything, just returns de exit code
  -c, --check   Check if a repository is valid
  -h, --help    Show this help'
end

