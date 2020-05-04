#!/usr/bin/env fish

# Environments variables
set -x EDITOR vim
set -x BROWSER google-chrome

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
alias e  'grep -E'
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
alias V  'sudo vim'
alias x  'xclip -selection clipboard'

# Alias (make flags always enabled)
alias echo_err 'set_color brred; echo -n "ERROR: "; set_color normal; echo'
alias fd 'fd -IHL --ignore-file ~/.config/fd/index-excludes'
alias ll 'ls -lhA --group-directories-first --color=always'
alias tree 'tree -aC'

# Colorman
source ~/.local/omf/pkg/colorman/init.fish
