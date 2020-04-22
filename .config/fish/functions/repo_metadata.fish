function repo_metadata
  argparse -s 'n/null' -- $argv
  test ! -f $repositories/$argv[1]; and return 1

  set metadata (sed '/^#!/,$d' $repositories/$argv[1])

  if set -q _flag_null
    echo $metadata | jq -e $argv[3] $argv[2] > /dev/null
  else
    echo $metadata | jq -re $argv[3] $argv[2]
  end

  return $status
end

