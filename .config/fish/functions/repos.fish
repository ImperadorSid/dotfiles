#!/usr/bin/env fish
function repos -d 'Manage repository downloads and script installations'
  set options 'e/edit' 'c/create' 'i/only-install' 'd/only-download' 'f/force-clone'
  argparse -x 'e,c,i,d' -x 'f,c,e' -X 2 $options -- $argv
  test $status -ne 0; and return 2

  set -g repo_file $argv[1]
  set -g repo_path "$repositories/$argv[1]"
  alias meta 'repo_metadata $repo_file'
  alias meta_quiet 'repo_metadata -n $repo_file'

  if set -q _flag_create
    echo 'Create'
  else if set -q _flag_edit
    echo 'Edit'
  end

  not __repos_check_file; and return 1

  set -g repo_name (meta '.repo')
  set -g repo_address (string match -qr '^https' $repo_name; and echo $repo_name; or echo "https://github.com/$repo_name")
  set repo_type (meta '.type')

  switch $repo_type
    case 'backup'
      echo 'Backup'
    case 'install'
      __repos_install "$_flag_only_download$_flag_only_install" "$_flag_force_clone"
    case 'release'
      echo 'Release'
    case *
      echo 'Repo type is invalid'
      __repos_cleanup_env
      return 3
  end

  __repos_cleanup_env
  return 0
end

function __repos_check_file
  if test ! -f $repo_path
    echo 'File doesn\'t exit'
  else if not repo_metadata -c $repo_file
    echo 'Repo metadata is invalid'
  else
    return 0
  end

  __repos_cleanup_env
  return 1
end

function __repos_cleanup_env
  set -e repo_file
  set -e repo_path
  set -e repo_name
  set -e repo_address
  set -e repo_location

  functions -e meta meta_quiet
end

function __repos_install
  __repos_find_location

  if test "$argv[1]" != '-i'
    test "$argv[2]" = '-f'; and rm -rf $repo_location
    g clone $repo_address $repo_location
  end

  if test "$argv[1]" != '-d'
    set current_location $pwd
    cd $repo_location; or return 1

    __repos_script | bash
    meta_quiet 'has("links")'; and __repos_links
    meta_quiet 'has("path_folders")'; and __repos_path_folders

    cd $current_location
  end
end

function __repos_script
  sed -n '/^#!/,$p' $repo_path
end

function __repos_links
  set links_count (meta '.links | length')
  for i in (seq 0 (math "$links_count - 1"))
    set destination (meta ".links[$i].destination" | sed -r 's|^~|/home/impsid|')
    test "$destination" = 'null'; and set destination '/home/impsid/.local/bin'
    mkdir -p $destination

    echo -e "\nCreating links in $destination"

    set files_count (meta ".links[$i].files | length")
    for j in (seq 0 (math "$files_count - 1"))
      set file_name (meta ".links[$i].files[$j]")
      ln -sf $file_name $destination
      echo "Link to $file_name created"
    end
  end
end

function __repos_find_location
  set -g repo_location (meta '.location' | sed -r 's|^~|/home/impsid|')
  if test "$repo_location" = 'null'
    set repo_location $repositories/(string replace -r '(.*)\.repo$' '$1' $repo_file)
  end
end

function __repos_path_folders
  echo 
  for f in (meta '.path_folders[]')
    if not contains $repo_location/$f $fish_user_paths
      echo "Adding folder \"$f\" to PATH"
      set -p fish_user_paths $repo_location/$f
    end
  end
end

