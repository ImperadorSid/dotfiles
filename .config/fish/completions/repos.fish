#!/usr/bin/env fish
function __repos_completions_list
  find $repositories -maxdepth 1 -name '*.repo' -exec fish -c 'repo_metadata -c (basename \{})' \; -printf '%f\tRepository: ' -exec fish -c 'repo_metadata (basename {}) ".repo"' \;
end
complete -f -c repos -a '(__repos_completions_list)' -d 'List avaliable repositories scripts'
