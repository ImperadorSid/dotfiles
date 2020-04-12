#!/usr/bin/env fish

# PATH variable
set -x TERM screen-256color
set -x PATH ~/.local/anaconda3/bin ~/.local/bin $PATH

# System configuraton folders
set -x repositories ~/Downloads/Linux/System/Repositories
set -x dotfiles $repositories/ImperadorSid@dotfiles
set -x system_files $repositories/ImperadorSid@system-files

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
alias t  'tree -C'
alias v  'vim'
alias V  's vim'
alias x  'xclip -selection clipboard'

