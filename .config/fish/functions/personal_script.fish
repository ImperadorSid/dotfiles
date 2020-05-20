#!/usr/bin/env fish

function personal_script
  argparse -n 'Personal script' 's/show-shell' -- $argv
  test -n "$argv"; or echo_err 'A script name must be passed as a parameter' 4; or return

  set script_name (ls $personal_scripts | grep $argv[1])
  set results_count (count $script_name)

  test "$results_count" -ne 0; or echo_err 'Script not found'; or return
  test "$results_count" -lt 2; or echo_err 'More than one script matches the input' 3; or return

  set script_full_path $personal_scripts/$script_name

  if string match -qr '\.fish$' $script_name
    fish $script_full_path $argv[2..-1]
  else if string match -qr '\.(ba)?sh$' $script_name
    bash $script_full_path $argv[2..-1]
  else
    set shell_executable (sed -nr '1 s/^#!(.*)/\1/p' $script_full_path)
    test -n "$shell_executable"
    and eval "$shell_executable $script_full_path $argv[2..-1]"
    or bash $script_full_path $argv[2..-1]
  end
end

