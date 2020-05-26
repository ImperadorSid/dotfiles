#!/usr/bin/env fish

function loading
  set options 'a/all' 'n/none' 'e/error' 'h/help'
  argparse -n 'Loading Spinner' -s -x 'a,n,e,h' $options -- $argv; or return

  set -q _flag_help; and __loading_help; and return

  test -n "$argv"; or echo_err "A command must be given"; or return

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

function __loading_help
  echo 'Loading spinner

Usage:
  loading [(-a | -n | -e | -h)] <commmand>

Options:
  -a, --all     Show all output (stdout/stderr)
  -n, --none    Hide all output
  -e, --error   Hide only the error output
  -h, --help    Show this help'
end

