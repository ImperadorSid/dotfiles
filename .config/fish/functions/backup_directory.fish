#!/usr/bin/env fish
function backup_directory
  set options 'd/diff' 'r/restore' 'e/edit' 'n/no-commit' 'j/just-commit'
  argparse -n 'Backup Directory' -N 2 -x 'd,r,n,j' -x 'e,r,j' $options -- $argv
  test "$status" -eq 0; or return

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
    echo_err 'File/directory not specified' 2
    return
  end

  test "x$argv[1]" = 'x-e'; and __backup_directory_backup_edit
  __backup_directory_backup_copy
  test "x$argv[2]" = 'x-n'; or __backup_directory_commit
end

function __backup_directory_backup_edit
  test -w "$fd_path"; and v $fd_path; or V $fd_path
end

function __backup_directory_backup_copy
  set destination_dir $repo_path/(dirname $relative_path)

  printf '%s%s%s ' (set_color yellow) "$fd_path" (set_color normal)
  test -e "$destination_dir/"(basename $fd_path); and echo 'updated'; or echo 'created'

  mkdir -p $destination_dir
  cp -r $fd_path $destination_dir
end

function __backup_directory_diff
  set current_directory $PWD
  $repo_path

  if test "x$argv" = 'x-e'
    __backup_directory_diff_all
  else if set -q fd_path
    __backup_directory_diff_single_file; or set diff_code $status
  else
    __backup_directory_diff_show
  end

  $current_directory
  return $diff_code
end

function __backup_directory_diff_single_file
  if test -d "$relative_path"
    echo_err "\"$fd_path\" is a directory" 6
  else
    __backup_directory_diff_file $relative_path
  end
end

function __backup_directory_diff_all
  set diffs (fd --type file --exec diff -q "$target_dir/{}" '{}' | awk '{print $4}')

  for d in $diffs
    __backup_directory_diff_file $d
  end
end

function __backup_directory_diff_show
  set diffs (fd --type file --exec diff -q "$target_dir/{}" '{}' | awk '{print $4}')
  set files_changed_count (count $diffs)

  if test "$files_changed_count" -gt 0
    echo 'Files with changes'
    for i in (seq $files_changed_count)
      printf '%3s %s%s%s\n' "$i" (set_color cyan) "$diffs[$i]" (set_color normal)
    end
  else
    echo 'All files are synched'
  end
end

function __backup_directory_diff_file
  test -w "$target_dir/$argv"; and v -d $target_dir/$argv $argv; or V -d $target_dir/$argv $argv
end

function __backup_directory_commit
  if test -d "$repo_path/.git"
    printf '\nCommiting changes\n'
    commit_repo $repo_path
  end
end

function __backup_directory_restore
  echo 'Restore'
end

function __backup_directory_init_variables
  if test ! -d "$argv[1]"
    echo_err "Directory \"$argv[1]\" doesn't exist" 5
    return
  end
  set -g target_dir $argv[1]

  set -g repo_name $argv[2]
  set -g repo_path $repositories/$argv[2]

  if set -q argv[3]
    if test ! -e "$argv[3]"
      echo_err "\"$argv[3]\" doesn't exist" 4
      return
    end

    set -g fd_path $argv[3]
    __backup_directory_check_relative
  end
end

function __backup_directory_check_relative
  set -g relative_path (realpath --relative-base=$target_dir $fd_path)

  if test (string sub -s 1 -l 1 $relative_path) = '/'
    echo_err "\"$fd_path\" isn't inside of \"$target_dir\"" 3
  end
end

function __backup_directory_unset_variables
  set -e target_dir

  set -e repo_name
  set -e repo_path

  set -e fd_path
  set -e relative_path
end

