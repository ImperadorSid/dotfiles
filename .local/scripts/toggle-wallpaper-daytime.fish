#!/usr/bin/env fish

set image $argv[1]
set brightness $argv[2]
set pictures_path '/home/impsid/Pictures'
set image_path $pictures_path/$image
set wallpaper_path "$pictures_path/wallpaper.png"
set dconf_background_path '/org/cinnamon/desktop/background/picture-uri'

if test ! -f "$image_path"
  echo_err "Image \"$image\" not found"
  exit
end

set actual_hour (date +%H)

if test "$actual_hour" -ge 17 -o "$actual_hour" -lt 9
  test -z "$brightness"; and set brightness 50

  set daytime 'Night'
else
  set brightness 100
  set daytime 'Day'
end

printf 'Setting %s%s%s as a wallpaper (%s%s%s mode, %s%s%%%s)\n' (set_color yellow) "$image" (set_color normal) (set_color cyan) "$daytime" (set_color normal) (set_color green) "$brightness" (set_color normal)

convert $image_path -modulate $brightness $wallpaper_path
dconf write $dconf_background_path "'file://$wallpaper_path'"

