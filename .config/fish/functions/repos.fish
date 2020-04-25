#!/usr/bin/env fish
function repos -d 'Manage repository downloads and script installations'
  set options 'e/edit' 'c/create' 'i/only-install' 'd/only-download' 'f/force-clear'
  argparse -n 'Repository Management' -x 'c,e,i,d' -x 'f,c,e' -X 2 $options -- $argv
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
  __repos_get_address
  set repo_type (meta '.type')

  switch $repo_type
    case 'backup'
      echo 'Backup'
    case 'clone' 'release'
      __repos_clone_release "$_flag_i$_flag_d" $_flag_f; or return 4
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
  set -e FILE_NAMES

  functions -e meta meta_quiet
end

function __repos_clone_release
  __repos_find_location
  set -gx FILE_NAMES

  test "$argv[1]" = '-i'; or __repos_download $argv[2]; or return 1
  test "$argv[1]" = '-d'; or __repos_install

  return 0
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

    for f in (meta ".links[$i].files[]")
      ln -sf $f $destination
      echo "Link to $f created"
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

function __repos_download
  test "$argv" = '-f'; and rm -rf $repo_location
  
  if test "$repo_type" = 'clone'
    g clone $repo_address $repo_location
  else
    if not __repos_get_files $argv 
      __repos_cleanup_env
      return 1
    end
  end

  return 0
end

function __repos_install
  set current_location $pwd
  cd $repo_location; or return 1

  __repos_script | bash
  meta_quiet 'has("links")'; and __repos_links
  meta_quiet 'has("path_folders")'; and __repos_path_folders

  cd $current_location
end

function __repos_get_files
  __repos_name_formatting; or return 1

  set targets_count (meta '.targets | length')
  for i in (seq 0 (math "$targets_count - 1"))
    set tag (meta ".targets[$i].tag" | sed -r 's/^null$/latest/') 
    set assets (__repos_tag_assets $tag $argv)

    echo "Release $tag"
    for f in (meta ".targets[$i].files[]")
      set file_info (echo $assets | jq -r "select(.name | test(\"$f\")) | .name, .browser_download_url")

      echo -n "  Downloading $file_info[1]... "
      a2 (test "$argv" = '-f'; or echo '-c') -q --allow-overwrite -d $repo_location $file_info[2]
      if test "$status" -ne 0
        echo -e "\n\nDownload failed. Aborting"
        return 1
      end
      echo 'finished'

      set -a FILE_NAMES $file_info[1]
    end
    echo
  end

  return 0
end

function __repos_get_address
  if string match -qr '^https' $repo_name
    set -g repo_address $repo_name
  else
    set -g repo_address "https://github.com/$repo_name"
  end

end

function __repos_name_formatting
  if string match -qrv '^[\w-]+/[\w-]+$' $repo_name
    echo 'To downloads releases from GitHub, the "repo" field must be formatted as <user>/<repo-name>'
    return 1
  end

  return 0
end

function __repos_tag_assets
  set uri_prefix "https://api.github.com/repos/$repo_name/releases"
  if test "$argv[1]" = 'latest'
    json_cache $argv[2] "$uri_prefix/latest" | jq '.assets[]'
  else
    json_cache $argv[2] "$uri_prefix?per_page=100" | jq ".[] | select(.tag_name == \"$argv[1]\").assets[]"
  end
end

