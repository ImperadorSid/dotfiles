#!/usr/bin/env fish

# Environments variables
set -x EDITOR vim
set -x BROWSER google-chrome
set -x MAKEFLAGS j 12

# System configuraton folders
set -x repositories ~/Downloads/Linux/System/Repositories
set -x dotfiles $repositories/dotfiles
set -x system_files $repositories/system-files

# Tasks file
set -x tasks_file ~/Documents/Books/Tasks/tasks.json

# Theme options
set -g theme_display_date no
set -g theme_nerd_fonts yes
set -g theme_color_scheme dracula

# Alias
alias a  'apt'
alias a2 'aria2c'
alias c  'clear; tmux clear-history'
alias g  'git'
alias i  'ipython'
alias j  'jupyter lab'
alias m  'man'
alias n  'npm'
alias N  'node'
alias p  'personal_script'
alias r  'repos'
alias sc 'sudo systemctl'
alias t  'tasks'
alias v  'vim'
alias V  'sudo (which vim)'
alias vf 'vifm'
alias x  'xclip -selection clipboard'

# Alias (make flags always enabled)
alias echo_err 'set_color brred; echo -n "ERROR: "; set_color normal; echo'
alias fd 'fd -IHL --ignore-file ~/.config/fd/index-excludes'
alias ll 'lsd -lA --group-dirs=first'
alias ls 'lsd -A --group-dirs=first'
alias tree 'tree -aC'

# Colorman
source ~/.local/omf/pkg/colorman/init.fish
