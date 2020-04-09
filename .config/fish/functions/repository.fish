#!/usr/bin/env fish

function repository -d "Local repositories management tool"
  if test (count $args) -gt 2
    echo 'Too many arguments. Expected 0-2 arguments'
    return 1
  end

  if test "$argv[1]" = '-e'
    set -g repo $argv[2]
  else
    set -g repo $argv[1]
  end

  # Check arguments
  if test (string length -q $repo) -eq 0;
    echo 'No repository specified'
    return 1
  end
  if not test -f $repositories/$repo
    echo "File $repo doesn't exist on repositories folder"
    return 1
  end

  # Create useful variables
  ssdasdaet repo_data (string split '@' $repo)
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

  __repository_errors $status
  return $status
end
# Print errors
function __repository_errors
  switch $argv
    case 1
      echo 'Syntax error found during read of targets files'
    case 2
      echo 'Connection error'
    end
 return $argv
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

  # Create directory if not exists
  set destination_folder "$repositories/$repo_user@$repo_name"
  if not test -d $destination_folder
    echo "Creating directory <repository-root>/$repo_user@$repo_name..."
    mkdir $repositories/$repo_user@$repo_name
  end

  echo "Getting files from repository \"$repo_user\":"

  # Download the target files
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
      set uri $uri_prefix/$uri_release/$f

      a2 -d $destination_folder -q --allow-overwrite $uri
      if test $status -ne 0
        echo "Error while retrieving file from <$uri>"
        return 2
      end
    end
  end
  echo "$download_count file(s) downloaded."

  # Execute install script
  echo "Executing install script..."
  set actual_folder (pwd)
  cd $destination_folder
  eval ../$repo

  # Erase variables and return to previous folder
  cd $actual_folder
  set -e repo
  set -e repo_name
  set -e repo_type
  set -e repo_user
  echo 'Finished'

end

