#!/usr/bin/env fish

function personal_script
  argparse -n 'Personal script' 's/show-shell' -- $argv
  if test -z "$argv"
    echo_err 'A task name must be passed as a parameter' 4
    return
  end

  set script_name (ls $personal_scripts | grep $argv[1])
  set results_count (count $script_name)

  if test "$results_count" -eq 0
    echo_err 'Script not found'
    return
  else if test "$results_count" -ge 2
    echo_err 'More than 1 script matches the input' 3
    return
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

    if test -n "$shell_executable"
      set -q _flag_show_shell; and echo "Using $shell_executable"
      eval "$shell_executable $script_full_path $argv[2..-1]"
    else
      set -q _flag_show_shell; and echo 'Trying running as a bash script'
      bash $script_full_path $argv[2..-1]
    end
  end

end

