#!/usr/bin/env fish
function backup_directory
  set options 'd/diff' 'r/restore' 'e/edit' 'n/no-commit' 'j/just-commit'
  argparse -n 'Backup Directory' -N 2 -x 'd,r,n' -x 'r,e,n' -x 'j,d,r,e,n' $options -- $argv
  test "$status" -eq 0; or return 1

  if __backup_directory_init_variables $argv
    if set -q _flag_diff
      __backup_directory_diff "$_flag_edit"
    else if set -q _flag_restore
      __backup_directory_restore
    else if set -q _flag_just_commit
      __backup_directory_commit
    else
      __backup_directory_backup "$_flag_edit" "$_flag_no_commit"
    end
  end

  set operation_code $status
  __backup_directory_unset_variables
  return $operation_code
end

function __backup_directory_backup
  if not set -q fd_path
    echo_err 'File/directory not specified'
    return 2
  end

  __backup_directory_edit_backup $argv[1]

  __backup_directory_commit $argv[2]

  return 0
end

function __backup_directory_edit_backup
  if test "x$argv" = 'x-e'
    test -w "$fd_path"; and v $fd_path; or V $fd_path
  end

  set destination_dir $repo_path/(dirname $relative_path)
  mkdir -p $destination_dir

  cp -r $fd_path $destination_dir
end

function __backup_directory_diff
  set current_directory $PWD
  $repo_path

  if set -q fd_path
    if test -d "$fd_path"
      echo_err "\"$fd_path\" is a directory"
      set result_code
    else
      __backup_directory_diff_single_file $relative_path
    end
  else
    __backup_directory_diff_all
  end

  $current_directory
  return 0
end

function __backup_directory_diff_single_file
  echo $target_dir/$argv
  test -w "$target_dir/$argv"; and v -d $target_dir/$argv $argv; or V -d $target_dir/$argv $argv

  return 0
end

function __backup_directory_diff_all
  set diffs (fd --type file --exec diff -q "$target_dir/{}" '{}' | awk '{print $4}')

  if test "x$argv" = 'x-e'
    for d in $diffs
      __backup_directory_diff_single_file $d
    end
  else
    echo 'Files with changes'
    for i in (seq (count $diffs))
      printf '%3s %s%s%s\n' "$i" (set_color cyan) "$diffs[$i]" (set_color normal)
    end
  end

  return 0
end

function __backup_directory_restore
  echo 'Restore'
end

function __backup_directory_commit
  if test "x$argv" != 'x-n'
    if test ! -d "$repo_path/.git"
      echo_err "Not a Git repository. Skipping commits..."
    else
      commit_repo $repo_path
    end
  end
end

function __backup_directory_init_variables
  if test ! -d "$argv[1]"
    echo_err "Directory \"$argv[1]\" doesn't exist"
    return 5
  end
  set -g target_dir $argv[1]

  set -g repo_name $argv[2]
  set -g repo_path $repositories/$argv[2]

  if set -q argv[3]
    if test ! -e "$argv[3]"
      echo_err "\"$argv[3]\" doesn't exist"
      return 4
    end
    set -g fd_path $argv[3]

    __backup_directory_check_relative
    return $status
  end

  return 0
end

function __backup_directory_check_relative
  set -g relative_path (realpath --relative-base=$target_dir $fd_path)

  if test (string sub -s 1 -l 1 $relative_path) = '/'
    echo_err "\"$fd_path\" isn't inside of \"$target_dir\""
    return 3
  end

  return 0
end

function __backup_directory_unset_variables
  set -e target_dir

  set -e repo_name
  set -e repo_path

  set -e fd_path
  set -e relative_path
end

