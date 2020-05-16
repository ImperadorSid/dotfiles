#!/usr/bin/env fish
function backup_directory
  set options 'd/diff' 'r/restore'
  argparse -n 'Backup Directory' -N 2 -x 'd,r' $options -- $argv
  test "$status" -eq 0; or return 1

  if __backup_directory_init_variables $argv
    if set -q _flag_diff
      __backup_directory_diff
    else if set -q _flag_restore
      __backup_directory_restore
    else
      __backup_directory_backup
    end
  end

  set return_code $status
  __backup_directory_unset_variables
  return $return_code
end

function __backup_directory_backup
  if not set -q file_path
    echo_err 'File not specified'
    return 2
  end

  set relative_path (realpath --relative-base=$target_dir $file_path)
  if test (string sub -s 1 -l 1 $relative_path) = '/'
    echo_err "The file \"$file_path\" isn't inside of \"$target_dir\""
    return 3
  end

  return 0
end

function __backup_directory_diff
  echo 'Diff'
end

function __backup_directory_restore
  echo 'Restore'
end

function __backup_directory_init_variables
  set -g target_dir $argv[1]
  set -g full_target_dir (realpath $target_dir)

  set -g repo_name $argv[2]
  set -g repo_path (realpath $repo_name)

  if set -q argv[3]
    if test ! -e "$argv[3]"
      echo_err "\"$argv[3]\" doesn't exist"
      return 4
    end

    set -g file_path $argv[3]
    set -g full_file_path (realpath $file_path)
  end

  return 0
end

function __backup_directory_unset_variables
  set -e target_dir
  set -e full_target_dir
  set -e repo_name
  set -e repo_path
  set -e file_path
  set -e full_file_path
end

