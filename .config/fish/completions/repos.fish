function __repos_completions_list
  find $repositories -maxdepth 1 -name '*.repo' -printf '%f\tRepository: ' -exec sh -c "sed '/^#!/,\$d' {} | jq -r '.repo'" \;
end
complete -f -c repos -a '(__repos_completions_list)' -d 'List avaliable repositories scripts'
