#!/usr/bin/env fish
set states '\u2807' '\u280B' '\u2819' '\u2838' '\u2834' '\u2826'
set delay 0.05
count $argv > /dev/null; and set delay $argv

printf ' '
while true
  for i in (seq (count $states))
    printf "\b$states[$i]"
    sleep $delay
  end
end
printf '\b'
