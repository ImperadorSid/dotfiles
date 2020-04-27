#!/usr/bin/env fish
function file_extension
  set name (string replace -r '(.+)\.\w+$' '$1' $argv)
  set extension (string replace -r '.+\.(\w+)$' '$1' $argv)

  if string match -qr '\.tar$' $name
    set extension "tar.$extension"
    set name (string replace -r '(.+)\.tar$' '$1' $name)
  end

  echo -e "$name\n$extension"
end

