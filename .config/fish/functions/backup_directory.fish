#!/usr/bin/env fish

function backup_directory
  set options 'd/diff' 'r/restore' 'e/edit' 'c/just-commit' 'h/help' 'i/ignore'
  argparse -n 'Backup Directory' -N 2 -x 'd,e,c,i,h' -x 'r,e,c,h,i' $options -- $argv; or return
  set current_directory $PWD

  set -q _flag_help
  and __backup_directory_help
  or \
    begin
      __backup_directory_init_variables $argv
      and $repo_path
      and \
        if set -q _flag_ignore
          __backup_directory_ignore_file
        else if set -q _flag_restore
          __backup_directory_restore $_flag_diff
        else if set -q _flag_just_commit
          __backup_directory_commit
        else
          __backup_directory_backup $_flag_edit $_flag_diff
        end
    end

  set operation_code $status
  __backup_directory_unset_variables

  $current_directory
  return $operation_code
end

function __backup_directory_backup
  argparse 'e/edit' 'd/diff' -- $argv

  if set -q fd_path
    if set -q _flag_edit
      __backup_directory_backup_edit
    else if set -q _flag_diff
      __backup_directory_backup_diff
    end
  else
    __backup_directory_check_changes; or return

    set -q _flag_diff
    and __backup_directory_backup_diff_all
    or __backup_directory_backup_list
  end

  __backup_directory_backup_make
  and __backup_directory_commit
end

function __backup_directory_backup_list
  echo 'Files with changes'
  for i in (seq $diffs_count)
    printf '%3s %s%s%s\n' "$i" (set_color cyan) "$diffs[$i]" (set_color normal)
  end
end

function __backup_directory_backup_edit
  __backup_directory_run_writable "$target_dir/$relative_path" vim $target_dir/$relative_path
end

function __backup_directory_backup_diff
  test -d "$relative_path"
  and echo_err "\"$fd_path\" is a directory" 6
  or __backup_directory_backup_diff_show $relative_path
end

function __backup_directory_backup_diff_all
  for d in $diffs
    __backup_directory_backup_diff_show $d
  end
end

function __backup_directory_backup_diff_show
  __backup_directory_run_writable "$target_dir/$argv" vim -d $target_dir/$argv $argv
end

function __backup_directory_backup_make
  __backup_directory_confirmation 'brmagenta' 'Make backup'; or return

  if set -q fd_path
    __backup_directory_backup_copy $relative_path
  else
    echo 'Updating changes'
    for d in $diffs
      __backup_directory_backup_copy $d
    end
  end
  echo
end

function __backup_directory_backup_copy
  set destination_dir $repo_path/(dirname $argv)

  printf '%s%s%s ' (set_color yellow) "$argv" (set_color normal)
  test -e "$destination_dir/"(basename $argv); and echo 'updated'; or echo 'created'

  mkdir -p $destination_dir
  cp -r $target_dir/$argv $destination_dir
end

function __backup_directory_restore
  __backup_directory_confirmation 'brblue' 'Are you sure'; or return

  if test "x$argv" = 'x-d'
    __backup_directory_restore_changed
  else if set -q fd_path
    __backup_directory_restore_file $relative_path
  else
    __backup_directory_restore_all
  end
end

function __backup_directory_restore_all
  printf 'Restoring backup from %s%s%s to %s%s%s...  ' (set_color yellow) "$repo_name" (set_color normal) (set_color blue) "$target_dir" (set_color normal)

  if not loading -a __backup_directory_run_writable "$target_dir" cp -r . $target_dir
    printf '\r'
    echo_err 'An error ocurred while restoring files'
  else
    echo 'complete'
  end

  set copy_code $status
  __backup_directory_run_writable "$target_dir/.git" rm -rf $target_dir/.{git,ignore-backup}
  return $copy_code
end

function __backup_directory_restore_file
  __backup_directory_run_writable "$target_dir/$argv" cp -r $argv $target_dir/$argv
  printf '%s%s%s was restored\n' (set_color cyan) "$argv" (set_color normal)
end

function __backup_directory_restore_changed
  __backup_directory_check_changes; or return

  echo 'Restoring changed files'
  for d in $diffs
    __backup_directory_restore_file $d
  end
end

function __backup_directory_commit
  test -f ".git/HEAD"; and echo 'Commiting changes...'; and commit_repo
end

function __backup_directory_changed_files
  test -f '.ignore-backup'; and set ignore_file '--exclude-from=.ignore-backup'
  set -g diffs (rsync -rin --checksum $ignore_file . $target_dir | grep '^>fc' | cut -d ' ' -f 2-)
  set -g diffs_count (count $diffs)
end

function __backup_directory_check_changes
  __backup_directory_changed_files

  if test "$diffs_count" -eq 0
    echo 'No files have been changed'
    return 1
  end
end

function __backup_directory_run_writable
  if test -w $argv[1]
    $argv[2..-1]
  else
    set command_path (which $argv[2])
    sudo $command_path $argv[3..-1]
  end
end

function __backup_directory_confirmation
  read -p "echo_color '$argv[1]' -en '\n$argv[2]? '; echo -n '[y/N] '" choice
  string match -qi 'y' $choice; or return
end

function __backup_directory_init_variables
  test -d "$argv[1]"; or echo_err "Directory \"$argv[1]\" doesn't exist" 5; or return

  set -g target_dir $argv[1]

  set -g repo_name $argv[2]
  set -g repo_path $repositories/$argv[2]

  if set -q argv[3]
    test -e "$argv[3]"; or echo_err "\"$argv[3]\" doesn't exist" 4; or return

    set -g fd_path $argv[3]
    __backup_directory_check_relative
  end
end

function __backup_directory_check_relative
  set -g relative_path (realpath --relative-base=$target_dir $fd_path)

  test (string sub -s 1 -l 1 $relative_path) != '/'
  or echo_err "\"$fd_path\" isn't inside of \"$target_dir\"" 3; or return

  test "$relative_path" != '.ignore-backup'
  or echo_err "The file \".ignore-backup\" cannot be used"
end

function __backup_directory_unset_variables
  set -e target_dir

  set -e repo_name
  set -e repo_path

  set -e fd_path
  set -e relative_path

  set -e diffs
  set -e diffs_count
end

function __backup_directory_ignore_file
  mkdir -p $repo_path
  v .ignore-backup

  __backup_directory_commit
end

function __backup_directory_help
  echo 'Script to backup, restore and get changes of a target folder

Usage:
  backup_directory <target_dir> <repo_name> [-d] [<file>]
  backup_directory <target_dir> <repo_name> -e <file>
  backup_directory <target_dir> <repo_name> -r [(-d | <file>)]
  backup_directory <target_dir> <repo_name> [(-i | -c | -h)]

Options:
  -e, --edit          Open file for editing
  -d, --delete        Check diff on files
  -r, --restore       Restore files to <target_dir>
  -j, --just-commit   Just commit backup folder
  -i, --ignore-file   Open .ignore-backup
  -h, --help          Show this help'
end

