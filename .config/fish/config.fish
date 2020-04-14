#!/usr/bin/env fish

# PATH variable
set -x PATH ~/.local/anaconda3/bin ~/.local/bin $PATH

# System configuraton folders
set -x repositories ~/Downloads/Linux/System/Repositories
set -x dotfiles $repositories/ImperadorSid@dotfiles
set -x system_files $repositories/ImperadorSid@system-files

# Tasks file
set -x tasks_file ~/Documents/Books/Tasks/tasks.json

# Theme options
set -g theme_display_date no
set -g theme_nerd_fonts yes
set -g theme_color_scheme dracula

# Alias
alias a  'apt'
alias a2 'aria2c'
alias c  'clear; clear'
alias e  'grep -E'
alias g  'git'
alias j  'jupyter lab'
alias m  'man'
alias n  'npm'
alias N  'node'
alias p  'ipython'
alias r  'c; exec fish'
alias sc 's systemctl'
alias t  'tasks'
alias tr 'tree -C'
alias v  'vim'
alias V  'sudo vim'
alias x  'xclip -selection clipboard'

