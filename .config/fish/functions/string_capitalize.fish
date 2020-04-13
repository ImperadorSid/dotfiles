#!/usr/bin/env fish

function string_capitalize
  set single_string (string join ' ' $argv)
  set first_character (string sub -l 1 $single_string)
  set remaining_charaters (string sub -s 2 $single_string)
  set capitalized_character (string upper $first_character)

  echo $capitalized_character$remaining_charaters

end

