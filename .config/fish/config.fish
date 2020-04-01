#!/usr/bin/env fish

# PATH variable
set -x PATH ~/.anaconda3/bin ~/.android-dev/flutter/bin ~/.android-dev/sdk/cmdline-tools/latest/bin ~/.android-dev/sdk/platform-tools ~/.android-dev/sdk/emulator/ $PATH

# System configuraton folders
set -x dotfiles ~/Downloads/Linux/System/Linux/dotfiles
set -x system_files ~/Downloads/Linux/System/Linux/system-files

# Theme options
set -g theme_display_date no
set -g theme_display_nvm yes
set -g theme_display_sudo_user yes
set -g theme_color_scheme dracula

# Alias
alias a  'apt'
alias ar 'aria2c -x8'
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
