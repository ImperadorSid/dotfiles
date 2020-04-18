#!/usr/bin/env fish

function personal_script
  if not count $argv > /dev/null
    echo 'A task name must be passed as a parameter'
    return 4
  end

  set scripts_dir ~/.local/scripts
  set script_name (ls $scripts_dir | grep $argv[1])
  set results_count (count $script_name)

  if test $results_count -eq 0
    echo 'Script not found'
    return 1
  else if test $results_count -ge 2
    echo 'More than 1 script matches the input'
    return 3
  end

  set script_full_path $scripts_dir/$script_name

  if string match -qr '\.fish$' $script_name
    echo 'Using fish'
    fish $script_full_path $argv[2..-1]

  else if string match -qr '\.(ba)?sh$' $script_name
    echo 'Using bash'
    bash $script_full_path $argv[2..-1]

  else
    set shell_executable (sed -nr '1 s/^#!(.*)/\1/p' $script_full_path)

    if count $shell_executable > /dev/null
      echo "Using $shell_executable"
      eval "$shell_executable $script_full_path $argv[2..-1]"
    else
      echo 'Trying running as a bash script'
      bash $script_full_path $argv[2..-1]
    end
  end

end

