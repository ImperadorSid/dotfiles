#!/usr/bin/env fish
function repos -d 'Manage repository downloads and script installations'
  set options 'e/edit' 'c/create' 'i/only-install' 'd/only-download' 'f/force-clear' 'o/open' 'O/only-open'
  argparse -n 'Repository Management' -x 'c,e,i,d,O' -x 'f,e,i,O' -x 'o,c,O' -X 2 $options -- $argv
  test "$status" -ne 0; and return 1

  set final_status 0
  set -g repo_file $argv[1]
  set -g repo_path "$repositories/$repo_file"

  alias meta 'repo_metadata $repo_file'
  alias meta_quiet 'repo_metadata -n $repo_file'

  if set -q _flag_open
    __repos_open
  end

  if set -q _flag_only_open
    __repos_open
  else if set -q _flag_create
    __repos_create "$argv[2]" $_flag_f; or set final_status 2
  else if set -q _flag_edit
    __repos_edit; or set final_status 3
  else
    __repos_execute "$_flag_i$_flag_d" $_flag_f; or set final_status 4
  end

  __repos_cleanup_env
  return $final_status
end

function __repos_execute

  __repos_check_file; or return 1

  set -g repo_name (meta '.repo')
  __repos_get_address
  set -g repo_type (meta '.type')

  if contains $repo_type 'clone' 'release' 'tag'
    __repos_clone_release_tag $argv; and return 0
  else
    echo_err "Repo type \"$repo_type\" is invalid"
  end

  return 1
end

function __repos_check_file
  if test ! -f "$repo_path"
    echo_err "File \"$repo_file\" doesn't exit"
  else if not repo_metadata -c $repo_file
    echo_err 'Repo metadata is invalid'
  else
    return 0
  end

  return 1
end

function __repos_get_address
  if string match -qr '^https' $repo_name
    set -g repo_address $repo_name
  else
    set -g repo_address "https://github.com/$repo_name"
  end

end

function __repos_clone_release_tag
  __repos_find_location
  set -gx FILE_FULL_NAMES
  set -gx FILE_NAMES
  set -gx FILE_EXTENSIONS

  __repos_download $argv; or return 1
  test "$argv[1]" = '-d'; or __repos_install; or return 1

  echo -e '\nDONE'
  return 0
end

function __repos_find_location
  set -g repo_location (meta '.location' | sed -r "s|^~|$HOME|")
  if test "$repo_location" = 'null'
    set -g repo_location $repositories/(string replace -r '(.*)\.repo$' '$1' $repo_file)
  end
end

function __repos_download
  argparse 'f/force' 'i/only-install' 'd/only-download' -- $argv
  set -q _flag_force; and rm -rf $repo_location

  switch $repo_type
    case 'clone'
      __repos_clone $_flag_only_install
    case 'tag'
      __repos_tag $_flag_only_install $_flag_force; or return 1
    case '*'
      __repos_release $_flag_only_install $_flag_force; or return 1
  end

  return 0
end

function __repos_clone
  if test "$argv" = '-i'
    printf 'Repository %s%s%s\n' (set_color brred) "$repo_name" (set_color normal)
  else
    printf 'Cloning %s%s%s... ' (set_color brred) "$repo_name" (set_color normal)
    loading g clone -q $repo_address $repo_location
    test "$status" -eq 0; and echo 'complete'; or echo_err 'Clone failed. Skipping...'
  end
end

function __repos_tag
  __repos_name_formatting; or return 1
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
    __repos_download_file $tarball_name $uri_prefix/tarball/$tag $flag_force; or return 1
  end

  echo -n '  Extracting tarball... '
  loading tar xf $repo_location/$tarball_name -C $repo_location --strip-components=1
  echo 'finished'

  return 0
end

function __repos_release
  __repos_name_formatting; or return 1
  argparse 'f/force' 'i/only-install' -- $argv

  set targets_count (meta '.targets | length')
  for i in (seq 0 (math "$targets_count - 1"))
    set tag (meta ".targets[$i].tag" | sed -r 's/^null$/latest/')
    set assets (__repos_tag_assets $tag $_flag_force)

    if not count $assets > /dev/null
      echo_err "Repository \"$repo_name\" not found"
      return 1
    end

    printf 'Release %s%s%s\n' (set_color brred) "$tag" (set_color normal)
    for f in (meta ".targets[$i].files[]")
      set file_info (echo $assets | jq -r "select(.name | test(\"$f\")) | .name, .browser_download_url")

      __repos_append_file_variables $file_info[1]
      if set -q _flag_only_install
        printf '  File %s: %s%s%s\n' (count $FILE_NAMES) (set_color cyan) "$file_info[1]" (set_color normal)
      else
        __repos_download_file $file_info $_flag_force; or return 1
      end
    end
  end

  return 0
end

function __repos_name_formatting
  if string match -qrv '^[\w-]+/[\w-]+$' $repo_name
    echo_err "For download $repo_type"'s from GitHub, the "repo" key must be formatted as <user>/<repo-name>'
    return 1
  end

  return 0
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
  loading a2 (test "$argv[3]" = '-f'; or echo '-c') -q --allow-overwrite -d $repo_location -o $argv[1] $argv[2]
  if test "$status" -ne 0
    echo -e '\r'
    echo_err 'Download failed. Aborting'
    return 1
  end
  echo 'finished'

  return 0
end

function __repos_append_file_variables
  set -a FILE_FULL_NAMES $argv

  set split_file_name (file_extension $argv)
  set -a FILE_NAMES $split_file_name[1]
  set -a FILE_EXTENSIONS $split_file_name[2]
end

function __repos_install
  __repos_dependencies; or return 1

  __repos_script; or return 1

  __repos_packages
  __repos_links
  __repos_path_folders

  return 0
end

function __repos_dependencies
  test (meta '.dependencies | length') -gt 0; or return 0

  set -g repo_dependencies (meta '.dependencies[]')

  if not dpkg -l $repo_dependencies &> /dev/null
    echo -e '\nInstalling dependencies:'
    printf '  %s... ' (__repos_print_dependencies)

    if not a install -y $repo_dependencies &> /dev/null
      echo -e '\r'
      echo_err 'Installation failed. Check the APT log for details'
      return 1
    end

    echo 'complete'
    return 0
  end
end

function __repos_print_dependencies
  set first_output true
  for d in $repo_dependencies
    $first_output; and set first_output false; or echo -n ', '

    set_color blue
    echo -n $d
    set_color normal
  end
end

function __repos_script
  set current_location $PWD
  cd $repo_location; or return 1

  set exec_file (mktemp)
  echo 'FILE_FULL_NAMES=($FILE_FULL_NAMES)' > $exec_file
  echo 'FILE_NAMES=($FILE_NAMES)' >> $exec_file
  echo 'FILE_EXTENSIONS=($FILE_EXTENSIONS)' >> $exec_file
  sed -n '/^#!/,$p' $repo_path >> $exec_file

  set_color yellow
  if test (wc -l < $exec_file) -gt 4
    echo -e '\nRunning installation script...'
    bash $exec_file
    echo -e 'Installation script finished'
  else
    echo -e '\nInstall script is empty. Skipping...'
  end
  set_color normal

  rm $exec_file
  cd $current_location

  return 0
end

function __repos_packages
  test (meta '.packages | length') -gt 0; or return

  echo -e "\nElevating privileges"
  sudo date > /dev/null

  for p in (meta '.packages[]')
    printf 'Installing package %s%s%s... ' (set_color magenta) $FILE_FULL_NAMES[$p] (set_color normal)
    sudo apt-get install -yq=2 $repo_location/$FILE_FULL_NAMES[$p] > /dev/null
    echo 'done'
  end
end

function __repos_links
  set links_count (meta '.links | length')
  set first_output true

  for i in (seq 0 (math "$links_count - 1"))
    set destination (meta ".links[$i].destination" | sed -r "s|^~|$HOME|")
    test "$destination" = 'null'; and set destination "$HOME/.local/bin"

    $first_output; and set first_output false; and echo
    printf 'Creating links in %s%s%s\n' (set_color green) "$destination" (set_color normal)

    for f in (meta ".links[$i].files[]")
      set f (string replace -r '^~' $HOME $f)
      set relative_path $repo_location/$f
      string match -qr '^/' $f; and set relative_path $f

      ln -sf $relative_path $destination
      printf '  Link to %s%s%s created\n' (set_color cyan) "$f" (set_color normal)
    end
  end
end

function __repos_path_folders
  test (meta '.path_folders | length') -gt 0; or return
  set first_output true

  for f in (meta '.path_folders[]')
    set f (string replace -r '^~' $HOME $f)
    set relative_path $repo_location/$f
    string match -qr '^/' $f; and set relative_path $f

    if not contains $relative_path $fish_user_paths
      $first_output; and set first_output false; and echo
      printf 'Adding folder %s%s%s to PATH\n' (set_color green) "$f" (set_color normal)

      set -p fish_user_paths $relative_path
    end
  end
end

function __repos_cleanup_env
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

  functions -e meta meta_quiet
end

function __repos_create
  set repo_path $repo_path.repo
  if test -f "$repo_path" -a 'x-f' != "x$argv[2]"
    echo_err 'Repository file already exists'
    return 1
  end
  test "$argv[1]" = ''; and set argv[1] 'release'
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
      return 1
  end

  echo $template | jq '.' > $repo_path
  echo '#!/usr/bin/env bash' >> $repo_path

  __repos_edit

  echo "Repository \"$repo_file\" ($argv[1]) created"
  return 0
end

function __repos_edit
  if test (count $repo_file) -eq 0
    v $repositories/*.repo
  else if test -f "$repo_path"
    v -c 'set filetype=sh | call cursor(3,12)' $repo_path
  else
    echo_err "Repo file \"$repo_file\" doesn't exist"
    return 1
  end

  return 0
end

function __repos_open
  if __repos_check_file
    __repos_find_location
    set destination $repo_location
  else
    echo 'Opening repositories folder...'
    set destination $repositories
  end

  cd $destination
  xdg-open $destination &> /dev/null
end

