#!/usr/bin/env fish
set -x PATH ~/.anaconda3/bin ~/.android-dev/flutter/bin ~/.android-dev/sdk/tools/bin ~/.android-dev/sdk/platform-tools ~/.android-dev/sdk/emulator/ ~/.nodejs/bin $PATH

set -x dotfiles ~/Downloads/Linux/Linux/dotfiles
set -x system_files ~/Downloads/Linux/Linux/system-files
set -x setup_files ~/Downloads/Linux/Linux/setup

alias a 'apt'
alias c 'clear; clear'
alias g git
alias jn 'jupyter-notebook'
alias p ipython
alias s sudo
alias sc 's systemctl'
alias sv 's vim'
alias v 'vim'
alias x 'xclip -selection clipboard'
