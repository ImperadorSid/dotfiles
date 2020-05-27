#!/usr/bin/env fish

# Environments variables
set -x BROWSER google-chrome
set -x EDITOR vim
set -x MAKEFLAGS j 12
set -x RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgreprc

# Useful locations
set -x repositories ~/Downloads/Linux/System/Repositories
set -x dotfiles $repositories/dotfiles
set -x system_files $repositories/system-files
set -x tasks_file ~/Documents/Books/Tasks/tasks.json
set -x personal_scripts ~/.local/scripts

# Theme options
set -g theme_display_date no
set -g theme_nerd_fonts yes
set -g theme_color_scheme dracula

# Alias
alias a  'apt'
alias a2 'aria2c'
alias b  'bat'
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
alias bdl 'backup_directory ~/Downloads/Linux installers'
alias bdot 'backup_directory ~ dotfiles'
alias bsys 'backup_directory / system-files'
alias fd 'fd -IHL --ignore-file ~/.config/git/ignore'
alias ip 'ip --color'
alias ll 'lsd -lA --group-dirs=first'
alias ls 'lsd -A --group-dirs=first'
alias tree 'ls --tree -I .git'

# Colorman
source ~/.local/omf/pkg/colorman/init.fish
