#!/usr/bin/env fish

function file_extension
  set name (string replace -r '(.+)\.\w+$' '$1' $argv)
  set extension (string replace -r '.+\.(\w+)$' '$1' $argv)

  string match -qr '\.tar$' $name
  and set extension "tar.$extension"
  and set name (string replace -r '(.+)\.tar$' '$1' $name)

  echo -e "$name\n$extension"
end

