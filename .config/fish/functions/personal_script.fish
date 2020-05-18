#!/usr/bin/env fish

function personal_script
  argparse -n 'Personal script' 's/show-shell' -- $argv
  if not count $argv > /dev/null
    echo 'A task name must be passed as a parameter'
    return 4
  end

  set script_name (ls $personal_scripts | grep $argv[1])
  set results_count (count $script_name)

  if test "$results_count" -eq 0
    echo 'Script not found'
    return 1
  else if test "$results_count" -ge 2
    echo 'More than 1 script matches the input'
    return 3
  end

  set script_full_path $personal_scripts/$script_name

  if string match -qr '\.fish$' $script_name
    set -q _flag_show_shell; and echo 'Using fish'
    fish $script_full_path $argv[2..-1]

  else if string match -qr '\.(ba)?sh$' $script_name
    set -q _flag_show_shell; and echo 'Using bash'
    bash $script_full_path $argv[2..-1]

  else
    set shell_executable (sed -nr '1 s/^#!(.*)/\1/p' $script_full_path)

    if count $shell_executable > /dev/null
      set -q _flag_show_shell; and echo "Using $shell_executable"
      eval "$shell_executable $script_full_path $argv[2..-1]"
    else
      set -q _flag_show_shell; and echo 'Trying running as a bash script'
      bash $script_full_path $argv[2..-1]
    end
  end

end

