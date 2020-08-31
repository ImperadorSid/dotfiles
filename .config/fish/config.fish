#!/usr/bin/env fish

# Environments variables
set -x BROWSER google-chrome
set -x EDITOR vim

# Useful locations
set -x repositories ~/Downloads/Linux/System/Repositories
set -x dotfiles $repositories/dotfiles
set -x system_files $repositories/system-files
set -x repo_scripts $repositories/scripts
set -x personal_scripts ~/.local/scripts
set -x tasks_file ~/Documents/Books/Tasks/tasks.json
set -x VCERT ~/Documents/Projects/SysISP/vcert.pem

# Theme options
set -g theme_display_date no
set -g theme_nerd_fonts yes
set -g theme_color_scheme dracula

# Alias
alias a  'apt'
alias a2 'aria2c'
alias b  'bat'
alias c  'clear'
alias g  'git'
alias i  'ipython'
alias j  'jupyter lab'
alias m  'man'
alias n  'nodemon'
alias N  'node'
alias p  'personal_script'
alias r  'repos'
alias sc 'sudo systemctl'
alias t  'tasks'
alias v  'vim'
alias V  'sudo (which vim)'
alias vf 'vifm'
alias x  'xclip -selection clipboard'
alias y  'yarn'

# Alias (make flags always enabled)
alias bdl 'backup_directory ~/Downloads/Linux installers'
alias bdot 'backup_directory ~ dotfiles'
alias bsys 'backup_directory / system-files'
alias fd 'fd -IHL --ignore-file ~/.config/git/ignore'
alias ip 'ip --color'
alias ll 'lsd -lA --group-dirs=first'
alias ls 'lsd -A --group-dirs=first'
alias snap 'sudo snap'
alias tree 'ls --tree -I .git'

