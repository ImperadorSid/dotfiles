#!/usr/bin/env fish

set pictures_path 'file:///home/impsid/Pictures'
set images 'Geraldo e Alberto.png' 'Geraldo e Alberto (Noturno).png'
set dconf_background_path '/org/cinnamon/desktop/background/picture-uri'

set actual_image (dconf read $dconf_background_path | tr -d '\'')

test $actual_image = "$pictures_path/$images[1]"; and set new_image "$pictures_path/$images[2]"; or set new_image "$pictures_path/$images[1]"
echo $new_image

dconf write $dconf_background_path "'$new_image'"

