#!/usr/bin/env fish

# PATH variable
set -x PATH ~/.local/anaconda3/bin ~/.local/flutter/bin ~/.local/android-sdk/cmdline-tools/latest/bin ~/.local/android-sdk/platform-tools ~/.local/android-sdk/emulator/ $PATH

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
alias e  'egrep'
alias g  'git'
alias j  'jupyter lab'
alias l  'less -N'
alias n  'npm'
alias N  'node'
alias p  'ipython'
alias s  'sudo'
alias sc 's systemctl'
alias sv 's vim'
alias v  'vim'
alias x  'xclip -selection clipboard'

# Abbreviations
abbr se 'sed -nr \'s|||p\''

# Change default mode
fish_vi_key_bindings
