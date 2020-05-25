#!/usr/bin/env fish

function compare_output
  argparse -n 'Compare Output' -s -x 'n,c,o,h' 'n/no-open' 'c/clear' 'o/open' 'h/help' -- $argv
  test "$status" -eq 0; or return

  set outputs_dir ~/.cache/fish_compare
  set -g current $outputs_dir/current.txt
  set -g previous $outputs_dir/previous.txt

  if set -q _flag_help
    __compare_output_help
  else if set -q _flag_clear
    __compare_output_clear
  else if set -q _flag_open
    __compare_output_show
  else
    __compare_output_update "$_flag_no_open" $argv
  end

  set exit_code $status
  __compare_output_unset_variables
  return $exit_code
end

function __compare_output_update
  test -n "$argv[2..-1]"; or echo_err "A command is required as a argument" 2; or return
  touch $current
  mv $current $previous

  eval "$argv > $current"

  set command_code $status
  test "x$argv[1]" != 'x-n'; and __compare_output_show
  return $command_code
end

function __compare_output_show
  v -d $current $previous
end

function __compare_output_clear
  rm $current $previous
end

function __compare_output_unset_variables
  set -e current
  set -e previous
end

function __compare_output_help
  echo 'Tool for compare the current output with a last one

Usage:
  compare_output [(-n | -c )] <command>
  compare_output -h

Options:
  -n, --no-open   Do not open diff after command finish
  -c, --clear     Clear cache files (current.txt and previous.txt)
  -h, --help      Show this help'
end

