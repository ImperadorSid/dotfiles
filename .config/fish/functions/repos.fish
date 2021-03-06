#!/usr/bin/env fish

function repos -d 'Manage repository downloads and script installations'
  set options 'e/edit' 'c/create' 'i/only-install' 'd/only-download' 'f/force-clear' 'o/open' 'O/only-open' 'r/reindex' 'h/help'
  argparse -n 'Repository Management' -x 'c,e,i,d,O,h' -x 'f,e,i,O,h' -x 'o,c,O,h' $options -- $argv; or return

  set current_directory $PWD
  alias meta 'repo_metadata $repo_file'
  alias meta_quiet 'repo_metadata -n $repo_file'

  ~
  set -g repo_alias "$argv[1]"
  set -g repo_file "$repo_alias.repo"
  set -g repo_path "$repo_scripts/$repo_file"

  set -q _flag_open; and __repos_open
  if set -q _flag_help
    __repos_help
  else if set -q _flag_only_open
    __repos_open
  else if set -q _flag_reindex
    __repos_index '-v'
  else if set -q _flag_create
    __repos_create "$argv[2]" $_flag_f
  else if set -q _flag_edit
    __repos_edit
  else if test (count $argv) -gt 1
    __repos_execute_multiple "$_flag_i$_flag_d" "$_flag_f" $argv
  else
    __repos_execute "$_flag_i$_flag_d" "$_flag_f"
  end

  set exit_code $status
  __repos_unset_variables
  functions -e meta meta_quiet
  $current_directory
  return $exit_code

end

function __repos_execute_multiple
  for r in $argv[3..-1]
    ~
    set -g repo_file "$r.repo"
    set -g repo_path "$repo_scripts/$repo_file"

    __repos_execute "$argv[1]" "$argv[2]"; or set -a failed_repos $r

    __repos_unset_variables
    echo
  end

  test -z "$failed_repos"
  and echo_color 'green' 'All repos was successful installed'
  or echo_err Repositories (set_color red)(string join ', ' $failed_repos)(set_color normal) failed to execute
end

function __repos_execute
  __repos_check_file; or return

  set -g repo_name (meta '.repo')
  __repos_get_address
  set -g repo_type (meta '.type')

  if contains $repo_type 'clone' 'release' 'tag'
    __repos_clone_release_tag $argv
  else
    echo_err "Repo type \"$repo_type\" is invalid"
  end
end

function __repos_check_file
  if test ! -f "$repo_path"
    echo_err "File \"$repo_file\" doesn't exit"
  else if not repo_metadata -c $repo_file
    echo_err 'Repo metadata is invalid'
  end
end

function __repos_get_address
  string match -qr '^https' $repo_name
  and set -g repo_address $repo_name
  or set -g repo_address "https://github.com/$repo_name"
end

function __repos_clone_release_tag
  __repos_find_location
  set -gx FILE_FULL_NAMES
  set -gx FILE_NAMES
  set -gx FILE_EXTENSIONS

  __repos_download $argv; or return
  test "$argv[1]" = '-d'; or __repos_install; or return
end

function __repos_find_location
  set -g repo_location (meta '.location' | sed -r "s|^~|$HOME|")

  test "$repo_location" = 'null'
  and set -g repo_location $repo_scripts/(string replace -r '(.*)\.repo$' '$1' $repo_file)
end

function __repos_download
  argparse 'f/force' 'i/only-install' 'd/only-download' -- $argv
  set -q _flag_force; and rm -rf $repo_location

  switch $repo_type
    case 'clone'
      __repos_clone $_flag_only_install
    case 'tag'
      __repos_tag $_flag_only_install $_flag_force
    case '*'
      __repos_release $_flag_only_install $_flag_force
  end
end

function __repos_clone
  if test "$argv" = '-i'
    printf 'Repository %s%s%s\n' (set_color brred) "$repo_name" (set_color normal)
  else
    printf 'Cloning %s%s%s... ' (set_color brred) "$repo_name" (set_color normal)
    loading g clone -q $repo_address "'$repo_location'"
    and echo 'complete'
    or echo_err 'Clone failed. Skipping...'
  end

  return 0
end

function __repos_tag
  __repos_name_formatting; or return
  argparse 'f/force' 'i/only-install' -- $argv

  set uri_prefix https://api.github.com/repos/$repo_name
  set tag (meta '.tag' | sed -r 's/^null$/latest/')
  test "$tag" = 'latest'; and set tag (json_cache $_flag_force $uri_prefix/tags | jq -r '.[0].name')
  set tarball_name $tag.tar.gz

  printf 'Tag %s%s%s\n' (set_color brred) "$tag" (set_color normal)

  if set -q _flag_only_install
    set tmp_tar (mktemp)
    mv $repo_location/$tarball_name $tmp_tar

    rm -rf $repo_location
    mkdir -p $repo_location
    mv $tmp_tar $repo_location/$tarball_name
  else
    __repos_download_file $tarball_name $uri_prefix/tarball/$tag $flag_force; or return
  end

  echo -n '  Extracting tarball... '
  loading tar xf $repo_location/$tarball_name -C $repo_location --strip-components=1
  echo 'finished'
end

function __repos_release
  __repos_name_formatting; or return
  argparse 'f/force' 'i/only-install' -- $argv

  set targets_count (meta '.targets | length')
  for i in (seq 0 (math "$targets_count - 1"))
    set tag (meta ".targets[$i].tag" | sed -r 's/^null$/latest/')
    set assets (__repos_tag_assets $tag $_flag_force)

    test -n "$assets"; or echo_err "Repository \"$repo_name\" not found"; or return

    printf 'Release %s%s%s\n' (set_color brred) "$tag" (set_color normal)
    for f in (meta ".targets[$i].files[]")
      set file_info (echo $assets | jq -r "select(.name | test(\"$f\")) | .name, .browser_download_url")

      __repos_append_file_variables $file_info[1]
      if set -q _flag_only_install
        printf '  File %s: %s%s%s\n' (count $FILE_NAMES) (set_color cyan) "$file_info[1]" (set_color normal)
      else
        __repos_download_file $file_info $_flag_force; or return
      end
    end
  end
end

function __repos_name_formatting
  string match -qr '^[\w-]+/[\w-]+$' $repo_name
  or echo_err "For download $repo_type"'s from GitHub, the "repo" key must be formatted as <user>/<repo-name>'
end

function __repos_tag_assets
  set uri_prefix "https://api.github.com/repos/$repo_name/releases"
  if test "$argv[1]" = 'latest'
    json_cache $argv[2] "$uri_prefix/latest" | jq '.assets[]' 2> /dev/null
  else
    json_cache $argv[2] "$uri_prefix?per_page=100" | jq ".[] | select(.tag_name == \"$argv[1]\").assets[]" 2> /dev/null
  end
end

function __repos_download_file
  printf '  Downloading %s%s%s... ' (set_color cyan) $argv[1] (set_color normal)

  set aria2_flags (test "x$argv[3]" = 'x-f'; or echo '-c')
  loading  a2 $aria2_flags --allow-overwrite -d $repo_location -o $argv[1] $argv[2]

  if test "$status" -eq 0
    echo 'finished'
  else
    echo -e '\r'
    echo_err 'Download failed. Aborting'
  end
end

function __repos_append_file_variables
  set -a FILE_FULL_NAMES $argv

  set split_file_name (file_extension $argv)
  set -a FILE_NAMES $split_file_name[1]
  set -a FILE_EXTENSIONS $split_file_name[2]
end

function __repos_install
  __repos_dependencies; or return

  __repos_script; or return

  __repos_packages
  __repos_links
  __repos_path_folders
end

function __repos_dependencies
  test (meta '.dependencies | length') -eq 0; and return

  set -g repo_dependencies (meta '.dependencies[]')

  if not dpkg -s $repo_dependencies &> /dev/null
    echo -e '\nInstalling dependencies:'
    printf '  %s... ' (__repos_print_dependencies)

    if loading sudo apt install -y $repo_dependencies
      echo 'complete'
    else
      printf '\r'
      echo_err 'Installation failed. Check the APT log for details'
    end
  end
end

function __repos_print_dependencies
  set first_output true
  for d in $repo_dependencies
    $first_output; and set first_output false; or echo -n ', '

    printf '%s%s%s' (set_color blue) "$d" (set_color normal)
  end
end

function __repos_script
  cd $repo_location; or return

  set exec_file (mktemp)
  echo 'FILE_FULL_NAMES=($FILE_FULL_NAMES)' > $exec_file
  echo 'FILE_NAMES=($FILE_NAMES)' >> $exec_file
  echo 'FILE_EXTENSIONS=($FILE_EXTENSIONS)' >> $exec_file
  sed -n '/^#!/,$p' $repo_path >> $exec_file

  set_color yellow
  if test (wc -l < $exec_file) -gt 5
    printf '\nRunning installation script...'
    bash $exec_file
    echo 'Installation script finished'
  end
  set_color normal

  rm $exec_file
end

function __repos_packages
  test (meta '.packages | length') -eq 0; and return

  for p in (meta '.packages[]')
    printf 'Installing package %s%s%s... ' (set_color magenta) $FILE_FULL_NAMES[$p] (set_color normal)
    loading sudo apt-get install -yq=2 $repo_location/$FILE_FULL_NAMES[$p]
    echo 'done'
  end
end

function __repos_links
  set links_count (meta '.links | length')
  set first_output true

  for i in (seq 0 (math "$links_count - 1"))
    cd $repo_location
    set destination (meta ".links[$i].destination" | sed -r "s|^~|$HOME|")
    test "$destination" = 'null'; and set destination "$HOME/.local/bin"

    $first_output; and set first_output false; and echo
    printf 'Creating links in %s%s%s\n' (set_color green) "$destination" (set_color normal)

    for f in (meta ".links[$i].files[]")
      set f (string replace -r '^~' $HOME $f)
      eval "set relative_path $f"
      string match -qr '^/' $f; and set relative_path $f

      ln -sf (realpath $relative_path) $destination
      printf '  Link to %s%s%s created\n' (set_color cyan) "$relative_path" (set_color normal)
    end
  end
end

function __repos_path_folders
  test (meta '.path_folders | length') -eq 0; and return
  set first_output true

  for f in (meta '.path_folders[]')
    set f (string replace -r '^~' $HOME $f)
    eval "set relative_path $f"
    string match -qr '^/' $f; and set relative_path $f

    if not contains $relative_path $fish_user_paths
      $first_output; and set first_output false; and echo
      printf 'Adding folder %s%s%s to PATH\n' (set_color green) "$relative_path" (set_color normal)

      set -p fish_user_paths (realpath $relative_path)
    end
  end
end

function __repos_unset_variables
  set -e repo_alias
  set -e repo_file
  set -e repo_path
  set -e repo_name
  set -e repo_address
  set -e repo_location
  set -e repo_type
  set -e repo_dependencies

  set -e FILE_FULL_NAMES
  set -e FILE_NAMES
  set -e FILE_EXTENSIONS

end

function __repos_create
  if test -f "$repo_path" -a 'x-f' != "x$argv[2]"
    echo_err 'Repository file already exists'
    return
  end

  test -z "$argv[1]"; and set argv[1] 'release'
  set type '"type": "'$argv[1]'"'
  set repo '"repo": ""'
  set location '"location": ""'
  set links '"links": [{"destination": "", "files": []}]'
  set path_folders '"path_folders": []'
  set targets '"targets": [{"tag": "", "files": []}]'
  set tag '"tag": ""'
  set dependencies '"dependencies": []'
  set packages '"packages": []'

  switch $argv[1]
    case 'clone'
      set template "{$type, $repo, $location, $dependencies, $links, $path_folders}"
    case 'tag'
      set template "{$type, $repo, $location, $dependencies, $links, $path_folders, $tag}"
    case 'release'
      set template "{$type, $repo, $location, $links, $path_folders, $targets, $packages}"
    case '*'
      echo_err "Type \"$argv[1]\" is not valid"
      return
  end

  echo $template | jq '.' > $repo_path
  printf '#!/usr/bin/env bash\n\n' >> $repo_path

  __repos_edit

  printf 'Repository %s%s%s (%s%s%s) created\n' \
  (set_color yellow) "$repo_file" (set_color normal) \
  (set_color cyan) "$argv[1]" (set_color normal)
end

function __repos_edit
  if test -z "$repo_file"
    v $repo_scripts/*.repo
  else if test -f "$repo_path"
    v -c 'set filetype=sh | call cursor(3,12)' $repo_path

    __repos_index_update_location
    __repos_index
  else
    echo_err "Repo file \"$repo_file\" doesn't exist"
    return
  end
end

function __repos_open
  if __repos_check_file
    __repos_find_location
    set destination $repo_location
  else
    echo 'Opening repositories folder...'
    set destination $repo_scripts
  end

  cd $destination
  xdg-open $destination &> /dev/null
end

function __repos_index_update_location
  set -g repo_name (meta '.repo')
  sed -ri "s|^($repo_alias) .*|\1 $repo_name|" $repo_scripts/.index
end

function __repos_index
  cd $repo_scripts
  set files (string replace -r '.repo$' '' (command ls))
  set index (awk '{print $1}' .index)

  for f in $files
    not contains $f $index
    and set -a added_repos $f
    and set -a addition_command "$f "(repo_metadata $f.repo '.repo')
  end
  test -n "$addition_command"
  and echo -e (string join '\n' $addition_command) >> .index

  for i in $index
    not contains $i $files
    and set -a deleted_repos $i
  end
  set deletion_command '/^'$deleted_repos' /d;'
  sed -i "$deletion_command" .index

  if test "x$argv" = 'x-v'
    count $added_repos > /dev/null
    and printf 'Index entries %s%s%s added\n' \
    (set_color cyan) (string join ', ' $added_repos) (set_color normal)
    and return

    count $deleted_repos > /dev/null
    and printf 'Index entries %s%s%s deleted\n' \
    (set_color yellow) (string join ', ' $deleted_repos) (set_color normal)
    and return

    echo_color 'green' 'Index already updated'
  end
end

function __repos_help
  echo 'Tool for download, installation and post-installation of Git repositories

Usage:
  repos -c [-f] [-o] <name> [<type>]
  repos -e [-o] [<repository>]
  repos -d [-f] [-o] <repository>
  repos -i [-o] <repository>
  repos -O | -r | -h

Options:
  -c, --create          Create repository
  -e, --edit            Edit repository
  -d, --only-download   Only download repository
  -i, --only-install    Only execute installation script
  -f, --force-clear     Recreate repository folder and clear request cache
  -o, --open            Change into repository dir and open it in file manager
  -O, --only-open       Only execute -o, nothing more
  -r, --reindex         Update index file
  -h, --help            Show this help'
end

