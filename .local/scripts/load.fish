#!/usr/bin/env fish

function __load_stop -s USR1
  set stop true
end

set stop false
set states '\u2807' '\u280B' '\u2819' '\u2838' '\u2834' '\u2826'
count $argv > /dev/null; and set delay $argv; or set delay 0.075

printf ' '
while not $stop
  for i in (seq (count $states))
    $stop; and break
    printf "\b$states[$i]"
    sleep $delay
  end
end

