#!/usr/bin/env fish

function __repos_completions_list
  awk '{print $1 "\tRepository: " $2}' $repo_scripts/.index
end
complete -f -c repos -a '(__repos_completions_list)' -d 'List avaliable repositories scripts'
complete -f -c repos -s e -l 'edit' -d 'Edit a repo script'
complete -f -c repos -s c -l 'create' -d 'Create a repo script'
complete -f -c repos -s i -l 'only-install' -d 'Execute only install-related operations'
complete -f -c repos -s d -l 'only-download' -d 'Execute only download-related operation'
complete -f -c repos -s f -l 'force-clear' -d 'Clear JSON cache and delete old files'
complete -f -c repos -s o -l 'open' -d 'Change into repo location and open with default file manager'
complete -f -c repos -s O -l 'only-open' -d 'Similar to -o option, but don\'t execute any other operation'
