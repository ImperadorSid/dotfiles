#!/usr/bin/env fish

function fish_user_key_bindings
  bind -M insert \e, 'v /home/impsid/.config/fish/config.fish'
  bind -M insert \e. 'vf /home/impsid/.config/fish/functions'
  bind -M insert \em 'vf .'
end

