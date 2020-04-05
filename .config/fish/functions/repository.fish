#!/usr/bin/env fish

function repository -d "Local repositories management tool"
  set -g repo $argv

  # Check of arguments
  if test (count $repo) -eq 0;
    echo 'No repository specified'
    return 1
  end
  if test (count $repo) -gt 1
    echo 'Too many arguments. Expected only one'
    return 1
  end
  if not test -f $repositories/$repo
    echo "File $repo doesn't exist on repositories folder"
    return 1
  end

  # Create useful variables
  set repo_data (string split '@' $repo)
  set -g repo_type $repo_data[1]
  set -g repo_user $repo_data[2]
  set -g repo_name $repo_data[3]

  # Option selection
  switch $repo_type
    case 'archive'
      __repository_archive
    case 'install'
      echo 'Install option'
    case 'standalone'
      echo 'Standalone option'
    case 'backup'
      echo 'Backup option'
  end

  switch $status
    case 1
      echo 'Syntax error found during read of targets files'
    end
end

# Manage "archive" option
function __repository_archive
  set targets (sed -nr 's|^## (.+)|\1|p' $repositories/$repo)
  set targets_count (count $targets)

  # Check if number of matchs is even
  if test (math "$targets_count % 2") -eq 1
    return 1
  end

  set releases $targets[(seq 1 2 $targets_count)]
  set files $targets[(seq 2 2 $targets_count)]
  set releases_count (count $releases)

  echo "Getting files from repository \"$repo_user\":"

  set destination_folder "$repositories/$repo_user@$repo_name"
  if not test -d $destination_folder
    echo "Creating directory <repository-root/>$repo_user@$repo_name..."
    mkdir $repositories/$repo_user@$repo_name
  end

  set uri_prefix "https://github.com/$repo_user/$repo_name/releases"
  set download_count 0
  for i in (seq $releases_count)
    if test $releases[$i] = 'latest'
      set uri_release 'latest/download'
    else
      set uri_release "download/$releases[$i]"
    end

    for f in (string split '/' $files[$i])
      echo "Downloading from release \"$releases[$i]\": $f..."
      set download_count (math "$download_count + 1")
      a2 -d $destination_folder -q --allow-overwrite $uri_prefix/$uri_release/$f
    end
  end

  echo "$download_count files downloaded."
  echo "Executing install script..."
  cd $destination_folder
  eval ../$repo
  echo 'Finished'

  set -e repo
  set -e repo_name
  set -e repo_type
  set -e repo_user

end

