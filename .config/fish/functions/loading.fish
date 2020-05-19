#!/usr/bin/env fish

function loading
  argparse -n 'Loading Spinner' -s -N 1 -x 'a,n,e' 'a/all' 'n/none' 'e/error' -- $argv
  test "$status" -eq 0; or return

  set redirection '> /dev/null'
  set -q _flag_all; and set redirection
  set -q _flag_none; and set redirection '&> /dev/null'
  set -q _flag_error; and set redirection '2> /dev/null'

  $personal_scripts/load.fish &
  set spinner_pid (jobs -lp)

  eval "$argv $redirection"
  set command_exit_code $status

  printf '\b'
  kill -USR1 $spinner_pid
  wait
  return $command_exit_code

end

