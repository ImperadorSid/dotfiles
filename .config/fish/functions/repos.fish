function repos -d 'Manage repository downloads and script installations'
  set options 'e/edit' 'c/create' 'i/only-install' 'd/only-download'
  argparse -x 'e,c,i,d' -X 2 $options -- $argv
  if test $status -ne 0
    __repos_unset
    return 2
  end

  set -g repo_file "$repositories/$argv[1]"

  if set -q _flag_create;
    echo 'Create'
  else if set -q _flag_edit
    echo 'Edit'
  end

  not __repos_check_file; and return 1
  echo 'Do something'

  __repos_unset
  return 0
end

function __repos_jq
  argparse 'n/null' -- $argv
  set -g metadata (sed '/^#!/,$d' $repo_file)

  if set -q _flag_null
    echo $metadata | jq -e "$argv[1]" > /dev/null
  else
    echo $metadata | jq -re "$argv[1]"
  end

  return $status
end

function __repos_check_file
  if test ! -f $repo_file
    echo 'File doesn\'t exit'
  else if not __repos_jq -n 'has("type")'
    echo 'Repo metadata is invalid'
  else
    return 0
  end

  __repos_unset
  return 1
end

function __repos_unset
  set -e repo_file
  set -e metadata
end

